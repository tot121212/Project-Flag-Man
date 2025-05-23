# Flag Man
Flag Man is a 2D Platformer set on the planet Mars!<br>
You play as a martian lad taking back his home planet from the evil lizards.<br>

## Video Demo
https://youtu.be/x-JFOjV3bZ0

## How to Play
Download the latest Windows Build from Releases

## Working Windows Build
https://github.com/tot121212/Project-Flag-Man_windows-build

## Languages

[GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)<br>
[C#](https://learn.microsoft.com/en-us/dotnet/csharp/)<br>

## Tools

[Github](https://github.com/)<br>
[Godot Game Engine](https://docs.godotengine.org/en/stable/about/introduction.html)<br>
[Aseprite](https://www.aseprite.org/)<br>
[Ableton](https://www.ableton.com/en/)<br>

## External Assets

[FMOD GDExtension for Godot Engine 4.0](https://github.com/utopia-rise/fmod-gdextension)<br>
[Input Helper](https://github.com/nathanhoad/godot_input_helper)<br>
[Phantom Camera](https://github.com/ramokz/phantom-camera)<br>

## Concept

Flag Man is a tech demo / video game made within the Godot game engine.<br>
It is an action platformer with a unique mechanic where-by the player can throw flags as projectiles and use frost magic to freeze them mid-air.<br> 
You can also create platforms and complete puzzles (puzzles not implemented yet).<br>

## Personal Notes

> I have tried to implement everything to be as modular as possible so as to be able to build the game faster.

> I think it worked out well in my opinion because I've gotten a decent amount done for my time, considering this is my first time using Godot;
Also considering I also made (basically) all of the assets (music/art included).

> I am really happy with how far I have come and although I have suffered difficulties along the way, I believe I am much better now at breaking down problems into more manageable parts and/or learning how to structure projects at-least even marginally better (although my code in some places is a mess...).

## GDD

[Game Design Document](https://en.wikipedia.org/wiki/Game_design_document)

## Story and Art
I started first with just a little guy waving flags around.<br>
I thought, what if I made the main character a little martian guy.<br>
Then I created the art for the mountainous area, based on some reference images of mars and my own experience visiting the Grand Canyon, which definitely helped.<br>
And after that I thought, people always talk about lizard men from mars in conspiracy theories, what if I just make those guys the antagonist. And thus the lizardmen were born.<br>
I won't go too deep into lore in this as its mainly just to see if i've learned computer science, not storytelling, so...<br>

## Mechanics
When I first started the project I had a plethora of ideas considered for the main mechanic but I ended up choosing the frozen projectile concept because it was the most extensible for new mechanics, like quenching fire, freezing liquids, etc.

#### Struggles and Shortcomings
One of the first things I had trouble with was learning the editor, all of the little quirks.<br>
Once I got over the hurdle of tutorial hell, things were actually a lot easier once I sat and actually picked apart problems, reading the proper wiki's when needed.<br>
AI and Navigation are still some things that need work but I just couldn't get them the way I wanted within the timespan I am afforded currently.<br>
Animations still need polish.<br>

## Programming
Let's get down to the nitty gritty.<br>

Many challenges were confronted in this project including but not limited to...
- Inheritence V.S. Composition
- Proper Class Structure
- Vectors
- Physics
- Ooodles and Ooodles of Object Oriented Programming
- State Machines ([Animation Trees](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html), Custom State Machines)
- [A* pathfinding algorithms](https://docs.godotengine.org/en/stable/classes/class_astar2d.html) [-----](https://www.youtube.com/watch?v=i0x5fj4PqP4) (Even though i ended up using the built-in navigation agents, which still use A*, its just more under the hood)
- [Save Systems](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html#json-vs-binary-serialization)

These were the most difficult for me to grasp, but there are plenty more things.

## Composition
As opposed to an is-a relationship between classes and its parents, nodes of the composition design technique have a has-a relationship, where-by classes can have instances of other classes inside of them.<br>
So instead of being strictly stuck to inherit all parts of its parent, it can just instance little pieces of information from various classes, increasing modularity.<br>
Godot handles this nicely with its node-based structure, ensuring maximum modularity between components. It is so easy to take each individual part and make something entirely new with just a few nodes.<br>

## Vectors and Normals
Vector math was a doozy, I suck at it.<br>
I had to watch like 3 or 4 videos to even get a grasp on it.<br>
But it's actually really simple once you get the hang of it, it kinda just clicked after awhile.<br>
In a similar vein, normals were equally confusing but alas.<br>
[This video really helped](https://www.youtube.com/watch?v=wgrKs6ItJUs)

## Save Systems
Save Systems are deceptively tricky to work with.<br>
In Godot, [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) and [ConfigFiles](https://docs.godotengine.org/en/stable/classes/class_configfile.html) are not safe for saving and loading data, due to code execution.<br>
So we have to come up with a different solution... <br>
Hmm, whats good at storing data and relatively safe.<br>
Oh, I know! JSON<br>
So we just use the [built-in json support](https://docs.godotengine.org/en/stable/classes/class_json.html) to save whatever data we need via...
- Dictionaries inside each node that needs to be saved that lists what data needs to be saved,
- A global SaveHandler, which does just as the name implies,
- Inside the SaveHandler, some helpful [signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) which tell each node with save data to run their co-responding save functions and use the returned dictionaries from said functions to store the save data,

And there we go!
(This took WAY longer than I thought it would.)
