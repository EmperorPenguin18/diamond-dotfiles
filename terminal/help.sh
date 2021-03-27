#!/bin/sh

describe ()
{
        printf "$1 -$(man -f $1 | cut -f 2- -d '-')\n"
}

echo "Basic commands:"
describe ls
describe cd
describe cp
echo

echo "Advanced commands:"
describe unzip
describe grep
describe whereis
echo

echo "Use 'man {command}' to learn more about a command"
