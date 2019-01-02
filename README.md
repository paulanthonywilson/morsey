# Morsey

The plan is to wire up a Raspbery Pi Zero to a telegraph key, to decode Morse and send messages to Slack.

## Vague plan

- [x] Ensure we're building the firmware onto a Pi
- [x] `init_gadget` and ability to upload new firmware over 
- [x] Be able to send messages to a Slack channel from host
- [x] Wifi
- [x] Send messages to Slack from Pi
- [x] Send key down, key up to Slack channel
- [x] Send dots, dashes to slack channel
- [x] Distinguish letters
- [x] Distinguish words
- [x] Decode
- [ ] Change dot timings from Slack
- [ ] Bundle words into slack messages

## Morse

From https://en.wikipedia.org/wiki/Morse_code#/media/File:International_Morse_Code.svg

![ITU Morse](morse.png)