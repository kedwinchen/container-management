# Container Management Shell Scripts

## TL;DR

Kind of a ripoff of `docker-compose` and similar tools, but primarily for
`podman` and written by a student in their free time for running development or
otherwise non-production containers on a single host.

---

## Detailed Explanation


### What?

A bunch of shell scripts I wrote to manage containers.


### Why?

I was/am using `podman` (for running containers as a non-root user by default),
and was getting annoyed with typing out full commands every time.
I was also tearing down containers fairly frequently and commands would get
lost and/or had to be mangled quite often despite command history.
This allowed me to be quicker in managing containers.


### Usage

If you are not me, I am not sure why you would want to use this.
`docker-compose` and `podman-compose` almost certainly work better and are
(almost definitely better suited for just about any workload)

Ok, so at this point I will assume you are going to use this.


#### "Installation"

0. Set up a Linux-based/UNIX-like host with either `docker` or `podman`
0. Drop these files in `/var/srv/containers`
0. Edit your [login] shell's RC file (e.g., `.bashrc`, `.zshrc`) file to source
   `/var/srv/containers/.bin/rc.bash` on login
0. Restart your shell (such as by logging out and in again)
0. Run `pps` (this should execute either `docker ps` or `podman ps`)

NOTE: Adding `/var/srv/containers/.bin/` to your `PATH` is NOT necessary, as
      `.bin/rc.bash` does this for you when you source the file

#### Compatibility

- Written with Linux-like hosts in mind
- Written for `bash` shell (but other compatible shells *should* work just
  fine; I do not think I am pulling any arcane dark magic arts in this
  collection of scripts...)
- Should work drop-in with `docker` or `podman` (or other tools with compatible
  command line syntax)
- Should "just work" with SELinux (shocker!) if the "root" of containers'
  folders are [based] in `/var/srv/containers`
