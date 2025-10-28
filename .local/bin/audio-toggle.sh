#!/bin/bash
# For PulseAudio, simple toggle between two sinks, get sink names by running: pactl list short sinks
SINK1="alsa_output.usb-MOTU_M2_M2AE29E6S5-00.HiFi__Line1__sink"
SINK2="alsa_output.usb-Logitech_G535_Wireless_Gaming_Headset-00.analog-stereo"
CURRENT=$(pactl get-default-sink)

if [ "$CURRENT" = "$SINK1" ]; then
    pactl set-default-sink "$SINK2"
else
    pactl set-default-sink "$SINK1"
fi

# Move all streams to new sink
for INPUT in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$INPUT" "$(pactl get-default-sink)"
done
