# Securepoint-Nagios-InterfaceStatus
Short Bash script to check the Interface Status (up/down) from Securepoint UTM over SNMP for Nagios/Icinga (or other services).

Installation for Nagios:
-----------------------

* Copy script to the libexec folder and make it executable with chmod +x check_interface_securepoint.sh
* Make sure snmp is enabled on the firewall and ports are open

Configuration in Nagios:
-----------------------

command definition (example):
```
# 'check_interface_securepoint' command definition
define command{
        command_name    check_interface_securepoint
        command_line    /usr/local/icinga/libexec/check_interface_securepoint.sh $HOSTADDRESS$ $ARG1$ $ARG2$ $ARG3$
        }
 ```

service definition (example):
 ```
define service{
        use                     generic-service
        host_name               SecurepointUTM
        service_description     status interface wan0
        check_command           check_interface_securepoint!public!2c!wan0
        }
 ```
