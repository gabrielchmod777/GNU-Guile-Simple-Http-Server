a simple http server that can serve static files

-----------------------
  it's made from code from Guile email archive

https://lists.gnu.org/archive/html/guile-user/2011-03/msg00061.html

----------------------

I am new to Scheme (gnu guile) and this is a
compilation from other people's work
>>> Credits to them!


Feel free to study and improve...and share ;) :D

License? .. hmmm ... >>> GNU GPL v3
https://www.gnu.org/licenses/gpl-3.0.en.html

Exception : Apple.png ... copied from internet

Usage:

in terminal:

    guile GuileSimpleWebServer.scm

in browser:

    localhost:8080/Apple.png       ->    displays the apple image
    localhost:8080/index.html      ->    displays the html page
    localhost:8080/Hello           ->    says: "Hello"

Have fun!!


TODO:

     - make the server stop ( admin custom request )
       (this is the hardest todo)

     - make possible to create new custom requests
     more easily ... (maybe in external files, like CGI scripts)


     - learn something about security
     - learn something about passwords and authentification
     
Note: project is very young (and a compilation of code found on internet)
     -- do not expect much -- :P :D :)
