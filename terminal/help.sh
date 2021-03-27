#!/bin/sh

NC='\033[1;0m'
WHITE='\033[1;37m'

describe ()
{
        printf "${WHITE}$1${NC} -$(man -f $1 | cut -f 2- -d '-')\n"
}

echo "Basic commands:"
describe ls
describe cd
describe cp
echo

echo "Intermediate commands:"
describe unzip
describe grep
describe find
echo

echo "Advanced commands:"
describe curl
describe dmidecode
describe whereis
echo

echo "Use 'man {command}' to learn more about a command"
