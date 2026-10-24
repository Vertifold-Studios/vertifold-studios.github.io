import AppKit
let size = NSSize(width: 1200, height: 630)
let image = NSImage(size: size)
image.lockFocus()
NSColor(calibratedRed: 11/255, green: 16/255, blue: 36/255, alpha: 1).setFill()
NSRect(origin: .zero, size: size).fill()
let cream = NSColor(calibratedRed: 242/255, green: 245/255, blue: 255/255, alpha: 1)
let blue = NSColor(calibratedRed: 120/255, green: 185/255, blue: 255/255, alpha: 1)
let muted = NSColor(calibratedRed: 179/255, green: 189/255, blue: 215/255, alpha: 1)
func text(_ s: String, _ x: CGFloat, _ y: CGFloat, _ font: CGFloat, _ color: NSColor, _ weight: NSFont.Weight = .regular) {
 (s as NSString).draw(at: NSPoint(x: x,y: y),withAttributes:[.font:NSFont.systemFont(ofSize:font,weight:weight),.foregroundColor:color])
}
text("VERTIFOLD STUDIOS",70,530,22,blue,.medium)
text("Small games.",65,335,86,cream,.semibold)
text("Big ideas.",65,235,86,blue,.semibold)
text("Puzzles with a mathematical twist.",70,165,24,muted)
text("vertifold.studio",70,65,19,muted)
let nodes: [NSPoint] = [.init(x:905,y:420),.init(x:1080,y:480),.init(x:1130,y:290),.init(x:970,y:200),.init(x:850,y:300)]
let edges = [(0,1),(1,2),(2,3),(3,4),(4,0),(0,2),(0,3),(1,3)]
NSColor(calibratedRed: 0.32,green: 0.46,blue: 0.7,alpha:1).setStroke()
for (a,b) in edges { let p=NSBezierPath();p.move(to:nodes[a]);p.line(to:nodes[b]);p.lineWidth=2;p.stroke() }
for (i,p) in nodes.enumerated() {
 let c = i == 2 ? NSColor(calibratedRed:0.57,green:0.75,blue:1,alpha:1) : blue
 c.setFill();NSBezierPath(ovalIn:NSRect(x:p.x-16,y:p.y-16,width:32,height:32)).fill()
}
image.unlockFocus()
let rep=NSBitmapImageRep(data:image.tiffRepresentation!)!
try rep.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:CommandLine.arguments[1]))
