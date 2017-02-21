# OBS plugin to compare sources in a project

## Setup

By default the plugin offers to compare to openSUSE:Factory. To make
it compare other projects, use the openSUSE:DiffTo attribute.

Teach OBS about the new attribute:

    $ cat > f << EOF
    <namespace name="openSUSE">
      <modifiable_by user="Admin"/>
    </namespace>
    EOF
    $ osc api -X PUT  /attribute/openSUSE/DiffTo/_meta -T f

    $ cat > f << EOF
    <definition name="DiffTo" namespace="openSUSE">
       <description>list of projects to offer diffing to</description>
       <modifiable_by role="maintainer"/>
    </definition>
    EOF
    $ osc api -X PUT  /attribute/openSUSE/DiffTo/_meta -T f

Set the attribute on a project

    $ meta attribute SUSE:SLE-12-SP3:GA -a openSUSE:DiffTo -c
    $ meta attribute SUSE:SLE-12-SP3:GA -a openSUSE:DiffTo -s openSUSE:Factory,openSUSE:Leap:42.3

## How to use

http://your.buildservice.org/project/compare/SUSE:SLE-12-SP3:GA

## TODO

https://github.com/openSUSE/open-build-service/issues/2726
