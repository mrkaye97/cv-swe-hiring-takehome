# Introduction

As of now (1/14/2021), [CollegeVine](collegevine.com) is hiring two new engineers! Part of our hiring process is a take-home project, where the task at hand is to code up an app that accepts lat / long coordinates and lists all of the schools within some provided distance of those coordinates. This is my R Shiny approach to that problem.

# Setup

The project is Dockerized, so setup is simple. 

1. Clone the repo
2. `cd` into the repo
3. `docker build -t foo .`
4. `docker run -d --rm -p 3838:3838 foo`

And that's it! You should be able to see the app at [http://0.0.0.0:3838/](http://0.0.0.0:3838/).
