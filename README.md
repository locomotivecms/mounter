# LocomotiveCMS Mounter

[![Gem Version](https://badge.fury.io/rb/locomotivecms_mounter.svg)](http://badge.fury.io/rb/locomotivecms_mounter)
[![Code Climate](https://codeclimate.com/github/locomotivecms/mounter.png)](https://codeclimate.com/github/locomotivecms/mounter)
[![Dependency Status](https://gemnasium.com/locomotivecms/mounter.png)](https://gemnasium.com/locomotivecms/mounter)
[![Build Status](https://travis-ci.org/locomotivecms/mounter.svg?branch=master)](https://travis-ci.org/locomotivecms/mounter)
[![Coverage Status](https://coveralls.io/repos/locomotivecms/mounter/badge.png)](https://coveralls.io/r/locomotivecms/mounter)

The "LocomotiveCMS Mounter" is a simple module to store in memory a LocomotiveCMS site whatever the source is:

* a site template built with the editor and on the local filesystem
* a zip file of a site template on the local filesystem
* a zip file of a site template but online through an url
* a LocomotiveCMS engine

It also includes a mechanism which could save the site from the memory to any targets (filesystem, another LocomotiveCMS engine, ...etc).
This saving mechanism has to be implemented in the application using that module.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
