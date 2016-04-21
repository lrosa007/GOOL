---
layout: post
title: "Initial Project Description"
date: 2016-04-21 17:05:00
categories: main
---
Students:

* Daniel Seoane - Computer Engineering
* Colburn Schacht - Electrical Engineering
* Lucas Rosa - Computer Science
* Stefan Lowe - Computer Science

**Significant contributor** - Dr. Mark Heinrich - EE & CS

### Motivations

This project is motivated by the problem of locating unmarked graves in cemeteries. Current solutions to this problem are unsatisfactory -- cemetery sextons are usually forced by time and budget constraints to rely on grave dowsing, an antiquated and pseudo-scientific technique that cannot produce reliable results. Other options are too invasive and/or prohibitively expensive, and may still be unreliable or require optimal conditions.

The objective of this project is to create a cheap but effective device that can scientifically detect the presence of coffins buried underground. Further objectives are to provide more information about detected graves. Coffin size, for example, can indicate whether a child or adult is buried. The type of material the casket is made from, how recently the soil was disturbed, and other factors may be useful as well. A secondary objective is to be able to identify skeletal remains that are not buried in a coffin.

 Our goal is to design a grave scanner that can connect to a mobile device like an iPad to offload processing signal data and displaying information. This should drastically reduce the amount of hardware needed, which helps keep the device cheap. Cost of the system is the most significant design constraint.

#### Daniel Seoane

My motivation for this project is to be able to have my first project where I’m able to incorporate software and  hardware design into the same project.  I’ve had projects where I make software, and projects where I design hardware, but never both at the same time for one big goal to provide this kind of technology to more people at an affordable price. My motivation comes when I was younger and my grandfather had told me about working for a graveyard back in Cuba. I asked him his advice on this project after Dr. Heinrich had come to our class and told us about it;  he talked to me about how most graveyards don’t have any funding whatsoever. It would be nice to be able to design a product that could be somewhat affordable for the government to purchase and lease out to different graveyards. All in all, this comes back to be able to show my grandfather that I did it take his advice and how big a part he actually does play in my life, I think this will be a very good decision for me to go on with this project.

#### Colburn Schacht

Over the past few years I've worked on a couple projects where I was tasked with working strictly in hardware or in software, and this project was so enticing because it included working on aspects of both to make one complete prototype. The opportunity to work with students of another discipline also seemed like an experience that would be extremely similar useful for work after school. It was an opportunity I couldn't pass up. Also after learning more about the current status of dowsing for graves and the situation cemeteries normally find themselves in budget wise, I saw it as a perfect way to help create a more affordable option for cemetery managers to keep track of genealogy, a big problem many cemeteries face. Not only that, but the applications of our device could also be expanded to forensic research in missing persons cases, allowing investigators a cheaper alternative to the current multi thousand dollar machines used for similar purposes.

#### Lucas Rosa

This was the only project that was between very related but different departments. As a Computer Science major I have spent a decent amount of time writing code. Being involved with a project in which I can learn more about hardware sounds more interesting than spending the entirety of the senior design project writing code. Before college, I wanted to study Electrical Engineering, so I feel like I can be involved in something I missed out on.

Many of the GPR devices on the market are quite expensive. The idea is to make a relatively portable and inexpensive device that can detect coffins in the ground. The method for this at cemeteries today is grave dowsing. It’s probably about time to modernize how this is done. If finding coffins ends up being successful we would like to consider taking a step forward and locate human remains without a coffin present. This could have forensic applications as well as assist search/rescue parties during disasters.

#### Stefan Lowe
My interest in this project was originally piqued by the unusual subject -- dead bodies and grave dowsing. On closer inspection, I found the practical applications and the challenges presented very fascinating, and I look forward to designing solutions. I was also attracted to this project because of its interdisciplinary nature. I’ve worked with teams of other programmers before, but I think the opportunity to work with engineers of different backgrounds will be a great learning experience.

### Broader Impacts

The unreliability of grave dowsing can cause sextons to sell or an occupied cemetery plot or damage a grave when digging a new one. This can create legal and emotional woes for both the sexton and the families of the buried persons. If we can create a sufficiently cheap and reliable alternative to grave dowsing, these situations can be avoided.

This project should have applications outside the graveyard as well. If we can reliably identify skeletal remains in addition to coffins, our results may see use in forensics -- finding missing persons -- and archeology.

### Requirements.

1. A method to send/receive electromagnetic signals
1. A method to filter noise *(dirt, water, plant matter, etc.)*
1. Portable, usable by one person
1. Inexpensive *(Ideally under $100 but at most $500)*
1. Send data to mobile device *(e.g. iPad, iPhone)*
1. Software on mobile device to analyze data
1. A user-friendly graphical interface

The scanner must be able to locate coffins up to six feet underground. Excluding the mobile device used for processing and display, the goal is to keep cost under $100. User interface and any data output should include GPS coordinates.

One component of the system will emit electromagnetic waves (likely ground-penetrating radar, GPR) into the ground and capture return signals. Some filtering of noise or other signal processing may occur before data are transmitted to the mobile device. An application on the mobile device will process the data and display any detected caskets or unusual objects in real time. Data may also be stored or sent to a database or the cloud for more intensive processing that cannot be performed in real time.

### Design Ideas

#### Lawn mower design

The Lawn mower design is supposed to have an ipad at the top or the handle of the product. It is to have sensing module at the base of it and maybe 3 or 4 wheels to allow easy transport and data acquisition. The IPad will receive data either wirelessly through means of either wifi or Bluetooth, depending on data bandwidth, or through a wired connection.

#### Dragging Design

Drag design is to be similar to the Lawn mower design except the module would be dragged instead of pushed, and the payload on the portion being dragged would be smaller, meaning an ancillary payload may be necessary to include all required electronics. A possible solution would be a backpack that would be connected directly to the portion being dragged.

#### Box Design

Box design would be box shaped device that would hold all the electronics above a metal rod located at the bottom. The user would plant the rod into the ground and electromagnetic waves would be transmitted outwards, via antenna, into the ground. A separate screen, ie. IPad or iPhone, would display the interpreted data to the user.

### Block Diagrams

![tasks diagram]({{ site.baseurl }}/assets/task_diagram.png)

### Project Budget and Financing

* Dr. Heinrich - Backing of approximately $500
* iOS Developer Fee - $99
* iPhone or iPad - to be acquired
* Wheels - $~13.04 each, (3 or 4 necessary)
* Antennas
* Receivers
* PCB(s)
* Misc. Electrical Components (Amplifiers, CPU, Resistors, etc...)

### Project Milestones

Our initial goal right now for the first semester is to have something that would only require implementation into the final project next semester. We want to have a test bed location determined before the new year begins. We also plan to have a design idea decided by early October. All of us plan to learn Swift, so we can all assist in the software development.

By next semester we not only plan to have a design that works, but it would also be able to discern whether or not the coffin beneath us is of a child or of an adult. We would begin testing early next semester to provide time to fix any issues that may arise. Being able to consistently and accurately determine the size and location of a coffin, if there is one, is our main goal. If we are able to meet that requirement we hope to expand our sensing capabilities to mere skeletons or tissue matter.
