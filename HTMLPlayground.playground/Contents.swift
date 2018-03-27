//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import HTMLAttributor

// Use this array to try different input HTML Strings.
let input = [
"""
Here are three of our favorite Pre-Woke Watching segments. Also, we're partnering with Slate’s video team to bring visuals to these conversations. Check out our<a href="https://slate.com/culture/2018/03/the-colorism-in-coming-to-america-is-hard-to-miss.html"> inaugural video </a>in this series.<br /><br />Hear more from actor, writer, and video producer Dylan Marron in <a href="http://www.slate.com/articles/podcasts/represent/2017/03/slate_represent_on_beauty_and_the_beast_and_every_single_word_creator_dylan.html">episode 36</a>.<br /><br />Tell a friend to subscribe! Share this link: <a href="http://megaphone.link/represent">megaphone.link/represent</a><br /><br />Email: represent@slate.com<br />Facebook:<a href="https://www.facebook.com/SlateRepresent/"> Slate Represent</a><br />Twitter:<a href="http://www.twitter.com/SlateRepresent"> @SlateRepresent</a>,<a href="http://www.twitter.com/craftingmystyle"> @craftingmystyle</a><br />Production by<a href="https://twitter.com/veralynmedia"> Veralyn Williams</a><br />Social media:<a href="https://twitter.com/miscivisci"> Marissa Martinelli</a>
""",
"""
There's been a drowning at the Pancake House.\n\nThis episode was co-written with Brie Williams.\n\nWeather: “Lake Full of Regrets” by Devine Carama featuring River Greene and Devin Roberts from the album Kingtucky.\n<a href=\"https://devinecarama.bandcamp.com\">https://devinecarama.bandcamp.com</a>\n\nADDED USA TOUR DATES of &quot;All Hail&quot; (Apr 2018). \n<a href=\"http://welcometonightvale.com/\">http://welcometonightvale.com</a>, click on live shows\n\nMusic: Disparition\n<a href=\"http://disparition.info/\">http://disparition.info</a>\n\nLogo: Rob Wilson\n<a href=\"http://robwilsonwork.com/\">http://robwilsonwork.com</a>\n\nWritten by Joseph Fink &amp; Jeffrey Cranor. Narrated by Cecil Baldwin. \n<a href=\"http://welcometonightvale.com/\">http://welcometonightvale.com</a>\n\nFollow us on Twitter <a href=\"https://twitter.com/nightvaleradio\">@NightValeRadio</a> or <a href=\"https://www.facebook.com/WelcomeToNightVale/\">Facebook</a>.\n\nProduced by Night Vale Presents. \n<a href=\"http://nightvalepresents.com/\">http://nightvalepresents.com</a>
""",
"In the late 1920s, the Ford Motor Company bought up millions of acres of land in Brazil. They loaded boats with machinery and supplies, and shipped them deep into the Amazon rainforest. Workers cut down trees and cleared the land and then they built a rubber plantation in the middle of one of the wildest places on earth. But Henry Ford wanted this community -- called “Fordlândia” -- to be more than just a huge plantation. He envisioned an industrial utopia. He paid his Brazilian workers good wages, at least for the region. And he tried to build them the kind of place he would’ve loved to live, which is to say: a small Midwestern town...but in the middle of the jungle.\n\n<a href=\"https://99percentinvisible.org/?p=24181&amp;post_type=episode\" target=\"_blank\">Fordlandia</a>\n\nIn the second segment, we discuss Roman’s other show <a href=\"https://trumpconlaw.com/\" target=\"_blank\">What Trump Can Teach Us About Con Law</a>"
]

let str = input[1]

let html = HTMLAttributor()
let tree = try! html.parse(str)
let a = try! html.attributedString(tree)

let data = str.data(using: .utf8)!
let b = try! NSAttributedString(data: data,
  options: [
    .documentType: NSAttributedString.DocumentType.html,
    .characterEncoding: String.Encoding.utf8.rawValue,
  ], documentAttributes: nil
)

let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 640, height: 1136))
PlaygroundPage.current.liveView = textView
textView.attributedText = a
