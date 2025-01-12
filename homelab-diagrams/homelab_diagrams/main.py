# diagram.py
from diagrams import Cluster, Diagram, Edge
from diagrams.generic.network import Router, Subnet, Switch
from diagrams.generic.compute import Rack

with Diagram("Homelab Network", show=False):
    landlord_router = Router("landlord's router\n(192.168.0.1)\nGateway")
    client_ap_router = Router("our router\nTenda AC1500\n(192.168.0.X)\n Client AP mode")

    with Cluster("Home Network\n10.83.0.0/16"):
        main_router = Switch("managed switch\nTP-Link ER605\n(port 2 and 5 unused)")
        main_ap = Router("Wi-Fi access point\nTP-Link AC1200\nMulti-SSID")

        with Cluster("DEFAULT VLAN"):
            vlan_default_subnet = Subnet("10.83.0.0/24\n(unused)")
            
        with Cluster("HOME VLAN"):
            vlan_home_subnet = Subnet("10.83.2.0/24")

        with Cluster("MANAGEMENT VLAN"):
            vlan_management_subnet = Subnet("10.83.4.0/24")

        with Cluster("GUEST VLAN"):
            vlan_guest_subnet = Subnet("10.83.6.0/24")

        with Cluster("WORK VLAN"):
            vlan_work_subnet = Subnet("10.83.8.0/24")

        with Cluster("DIY VLAN"):
            vlan_diy_subnet = Subnet("10.83.16.0/20")

            proxmox_server = Rack("Proxmox server\n10.83.16.99")

        main_router - Edge(label="port 3", color="blue") - vlan_diy_subnet 
        main_router - Edge(label="port 4", color="blue") - main_ap


        main_ap - Edge(label="ssid home", color="darkorange") - vlan_home_subnet
        main_ap - Edge(label="ssid management", color="darkorange") - vlan_management_subnet
        main_ap - Edge(label="ssid guest", color="darkorange") -  vlan_guest_subnet
        main_ap - Edge(label="ssid work", color="darkorange") - vlan_work_subnet
        main_ap - Edge(label="ssid diy", color="darkorange") - vlan_diy_subnet


    landlord_router - client_ap_router
    client_ap_router -  Edge(label="port 1", color="blue") - main_router



