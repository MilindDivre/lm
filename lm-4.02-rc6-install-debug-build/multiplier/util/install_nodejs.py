#!/usr/bin/python2.7

import commands
import os
import shutil
import subprocess
import sys

path = "/usr/local/multiplier/system/bin/multiplier"
os.chdir(path)
print "Nodejs installation in progress...."
subprocess.check_output('sudo apt-get -y  update', shell=True)

commands.getoutput('sudo apt-get -y install nodejs')
print "nodejs installed successfully..."

"""print subprocess.check_output('sudo apt-get install nodejs-dev node-gyp libssl1.0-dev', shell=True)"""
commands.getoutput('sudo apt-get -y install npm')
print "npm installed successfully..."

print subprocess.check_output('npm i puppeteer', shell=True)
print "puppeteer installed successfully..."


commands.getoutput('apt-get install -yq --no-install-recommends libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 libnss3')

Destination_path = sys.argv[1]
os.chdir(Destination_path)
subprocess.check_output('mkdir -p /usr/local/multiplier/device/fake/media', shell=True)
subprocess.check_output('cp -rp ../util/config/video-in.mjpeg /usr/local/multiplier/device/fake/media', shell=True)
subprocess.check_output('cp -rp ../util/config/audio-in.wav /usr/local/multiplier/device/fake/media', shell=True)

