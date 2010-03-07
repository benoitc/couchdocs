Valance is a graphical client for CouchDB.
== Dependencies ==
  * Python
  * GTK
  * PyGTK
  * Paisley
  * Twisted
== Features ==
Non-blocking access to CouchDB
Custom forms editable in Glade and stored in CouchDB
== Muses ==
It is helpful to think of a few fictional use-cases that stress the requirements in different ways. They are designed to make it easy to see when a design decision may have undesirable consequences.
=== The Venus Flyers ===
A few years in the future . . .

After the background radiation from the OOXML wars had subsided and large parts of the Earth were once again habitable, the global Free Software Alliance decided to investigate colonization of the upper atmosphere of [[http://en.wikipedia.org/wiki/Colonization_of_Venus|Venus]]. The first stage was to send a flock of solar powered flyers to study the conditions over the course of a few rotations.
The flyers all have a local CouchDB server on which they store logs from instruments and cameras. They replicate with each other or form a cluster when they have line of sight communications. Scientists back on Earth use the Valance client to work with the databases directly on the flyers (yes, they could use replication, but that isn't the point of this muse). They have plenty of bandwidth, but latency varies from two and a half, to fourteen and a half minutes each way. Nobody wants the client to lock up for half an hour just to get a bit of data so non-blocking network access is critical.
=== The OLPC Laptop ===
In this scenario a class full of kids have [[http://wiki.laptop.org|OLPC laptops]]. Each one has a Fedora core based operating system and the Sugar user interface. Each laptop runs CouchDB locally and the Valance client connects only to the local CouchDB server. The Sugar user interface is written in Python and the Valance client fits in with the other activities on the laptop. Kids use it to work on assignments from the teacher and to work collaboratively in small groups over the mesh network outside of school. In the classroom the teacher can ask questions and get answers from all the students to display on the screen of the teacher's laptop which is projected onto a wall.
=== The Tax Form ===
The government of Borogovia uses IBM Lotus Notes to process tax returns from it's citizens. They receive paper tax returns which are scanned and then follow a complex internal workflow, it works just perfectly. Now they want to extend this system out to the population so they can complete tax forms offline and replicate them in and perhaps have them come back with changes. Deploying a full Notes client to the population would be impossible to manage and cost far too much. They decide to use Valance and CouchDB to extend their Notes application outside their firewall to the population.
This muse requires scalability and bi-directional communication with a Notes infrastructure.
