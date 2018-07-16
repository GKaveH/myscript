#!/bin/bash
set -e
#
#============================================================================================
#This script can help you for IP configuration in debian 9
#date 1397/03/10 = 2018/07/10
#Kiani 
#============================================================================================


#============================================================================================
# Variable
#============================================================================================
KE=$( cat /etc/debian_version | cut -d. -f1 )
FL=bak$(date +%y%m%d%H%M%S)
EN1=$(ifconfig | grep "^en" | cut -b 1-6 | sed -n 1p)
EN2=$(ifconfig | grep "^en" | cut -b 1-8 | sed -n 1p)
EN3=$(ifconfig | grep "^en" | cut -b 1-8 | sed -n 2p)
EN4=$(cat network | grep -o dhcp) || true
EN5=$(cat network | grep -o static) || true
NE="/etc/network/interfaces"

#--------------------------------------------------------------------------------------------
# Variable for Coloring
#--------------------------------------------------------------------------------------------

green="\e[32m"
red='\033[0;31m'
bluewh="\e[34;107m"
redwh="\e[31;107m"
whitere="\e[97;41m"
whitebl="\e[97;104m"
NC='\033[0m' # No Color

#============================================================================================
# checking debian version
#============================================================================================


#if [[ $(bc <<< "$KE > 8.9") -eq 1 && $(bc <<< "$KE < 10.0") -eq 1  ]]; then

if [[ $KE -gt 8 && $KE -lt 10  ]]; then
	echo "Debian version is $KE"
	else
	echo "Debian version must be 9 or 9.*"
exit
fi



#===========================================================================================
# IP Setting
#===========================================================================================

cp /etc/network/interfaces /etc/network/interfaces.$FL

getinfo()
{
        echo ""
        read -p "static IP :                     " ip1
        read -p "netmask for your network:       " ip2
        read -p "ip address for your gateway:    " ip3
      }
no()
      {
        echo ""
              }

        clear

ipsetting()
{
        echo -e "${redwh}Lets start to Prepare your server${NC}"
        echo""
        echo""

#------------------------------------------------------------------------	
#DHCP setting
#------------------------------------------------------------------------

	while true; do
        read -p "Are you want to use DHCP ? [y/n]: " dhcp
        case $dhcp in

        [Yy]* )

        if [[ $EN4 = dhcp ]]; then

        echo ""
        echo ""
        echo -e "${red}The configuration file has already been modified . ${NC}"
        else
        cat >> $NE << EOF
auto $EN1
iface $EN1 inet dhcp
EOF
        echo ""
        echo ""
        echo -e "${green}Your configuration was succsesful and saved in '$NE' . ${NC}"
        echo ""
fi      ; break ;;


        [Nn]* ) no ; break ;;

        * ) echo "Pleas enter y or n!";;

        esac
  done

#------------------------------------------------------------------------
# Static IP setting without bond
#------------------------------------------------------------------------

        if [[ $dhcp = [Yy] ]]; then
        echo ""
        else
        while true; do
        read -p "Are you want to set Static IP without Bonding your network adapters ? [y/n]: " static

        case $static in

        [Yy]* )

        if [[ $EN5 = static ]]; then

        echo ""
        echo -e "${red}The configuration file has already been modified . ${NC}"

        else
                echo ""; echo "Please Enter your static IP setting  "
                getinfo;

                cat >> $NE << EOF

auto $EN1
iface $EN1 inet static
address $ip1
netmask $ip2
gateway $ip3
EOF
        echo ""
        echo ""
        echo -e "${green}Your configuration was succsesful and saved in '$NE' . ${NC}"
        echo ""
fi      ; break ;;
        [Nn]* ) no; break ;;

            * ) echo "Pleas enter y or n!";;
          esac
  done
fi

#------------------------------------------------------------------------
# Static IP setting with bonding
#------------------------------------------------------------------------

        if [[ $static = [Yy] ]] || [[ $dhcp = [Yy] ]] ; then

        echo ""
        else
        while true; do
        read -p "Are you want to set Static IP with Bonding your network adapters ? [y/n]: "  bond

        case $bond in

        [Yy]* )

        if [[ $EN5 = static ]]; then

        echo ""
        echo -e "${red}The configuration file has already been modified . ${NC}"
        else
                echo"" ; echo "Please Enter your static IP setting  "
                getinfo;

                cat >> $NE  << EOF
auto bond0
iface bond0 inet static
address $ip1
netmask $ip2
gateway $ip3
bond-slaves $EN2 $EN3
bond_mode 802.3ad
bond_miimon 100
bond_downdelay 200
bond_updelay 200
bond_xmit_hash_policy layer3+4
EOF
        echo ""
        echo ""
        echo -e "${green}Your configuration was succsesful and saved in '$NE' . ${NC}"
        echo ""
fi      ; break ;;
        [Nn]* ) no; break ;;

            * ) echo "Pleas enter y or n!";;
          esac
done
fi

#------------------------------------------------------------------------
# Warning and restart this script
#------------------------------------------------------------------------


        if [[ $dhcp = [Nn] ]] && [[ $static = [Nn] ]] && [[ $bond = [Nn]  ]]; then

        echo -e "${whitere}      WARNING          WARNING          WARNING          WARNING          WARNING          WARNING          WARNING          WARNING          WARNING          WARNING      ${NC}"
        echo ""
        echo -e "${red}YOU CHOOSE NO TO ALL IP CONFIGURATION SETTING

if you manualy set your ip configuration please answer yes to next question. ${NC}"
        echo ""
        read -p "ARE YOU SURE YOU WANT TO CONTINUE ? [y/n]: " needip
        echo ""
        case $needip in

        [Yy]* ) no;;
        [Nn]* )
        echo  -e "${redwh}be cool script restarted. ${NC}"
                echo ""
                ipsetting
                echo "";;
        * ) echo "Pleas enter y or n!";;
        esac
fi

}

ipsetting
