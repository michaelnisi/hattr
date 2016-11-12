//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import HTMLAttributor

let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 640, height: 1136))
let oak = HTMLAttributor()
let html = "<p>This week is National Alternate History Week. Plus an update on the Beatrix Lohman Memorial Meditation Zone, a warning from the National Weather Service, and Children's Fun Fact Science Corner.</p> <p>Weather: &quot;Opposite House&quot; by Cass McCombs (<a href=\"http://cassmccombs.com/\">cassmccombs.com</a>)</p> <p>New Books: Night Vale Podcast Episodes, Volumes 1 &amp; 2<br /> now available for pre-order<br /> Plus...<br /> Welcome to Night Vale: The Novel. <a href=\"http://welcometonightvale.com\">welcometonightvale.com</a>, click on book.</p> <p>Night Vale European Tour Dates:<br /> Oct 3-23, 2016<br /> <a href=\"http://welcometonightvale.com\">welcometonightvale.com</a>, click on live shows.</p> <p>NY/NJ Show:<br /> Aug 25, 2016<br /> <a href=\"http://welcometonightvale.com\">welcometonightvale.com</a>, click on live shows.</p> <p>Music: Disparition, <a href=\"http://disparition.info\">disparition.info</a>.</p> <p>Logo: Rob Wilson, <a href=\"http://robwilsonwork.com\">robwilsonwork.com</a>.</p> <p>Produced by Night Vale Presents. Written by Joseph Fink &amp; Jeffrey Cranor. Narrated by Cecil Baldwin. More Info: <a href=\"http://welcometonightvale.com\">welcometonightvale.com</a>, and follow <a href=\"http://twitter.com/NightValeRadio\">@NightValeRadio</a> on Twitter or <a href=\"http://facebook.com/welcometonightvale\">Facebook</a>.</p>"
let tree = try! oak.parse(html)
let text = try! oak.attributedString(tree)
textView.attributedText = text

PlaygroundPage.current.liveView = textView