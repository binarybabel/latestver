# Latestver

[![Docker Automated buil](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/binarybabel/latestver/)
[![AUR](https://img.shields.io/aur/license/yaourt.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![Join the chat at https://gitter.im/binarybabel/Latestver](https://badges.gitter.im/binarybabel/Latestver.svg)](https://gitter.im/binarybabel/Latestver?utm_source=badge&utm_medium=badge&utm_content=badge)

Dependency monitoring web-application featuring webhooks, JSON API, and project-level tracking.

**Hosted edition available at: [lv.binarybabel.org](https://lv.binarybabel.org)**

Supports tracking the latest versions of your favorite software via:

* Git repository tags
* RubyGems
* NPM Packages
* Web-page scraping

## Deploying Latestver Privately

Latestver is available as a Docker Image: [hub.docker.com/r/binarybabel/latestver](https://hub.docker.com/r/binarybabel/latestver/)

By default the application will be available from `http://localhost:3333`

```
docker run -p 3333:3333 -v $(pwd):/app/data --name latestver binarybabel/latestver
```

Alternatively, **docker-compose.yml**

```
version: '2'
services:
  app:
    images: binarybabel/latestver
    volumes:
      - .:/app/data
    ports:
      - "3333:3333"

```

## Customizing

### Environment variables and defaults

Catalog Settings

* __REFRESH\_ENABLED__
 * default: true - catalog versions refreshed automatically (at startup and set interval)
* __REFRESH\_INTERVAL__
 * default: 1h - how often catalog is refreshed, ex: _(7d, 1h, 15m, 60s)_
* __CACHE\_CONTROL\_MAX\_AGE__
 * default: 0 - how many seconds browsers or proxies may cache catalog results


Security Settings

* __ADMIN\_PASS__
 * no default - if set admin pages are password protected
* __ADMIN\_USER__
 * default: admin

### Custom Catalog Entries

You can create custom catalog models for advanced version checking.

**Here are some code references:**

* [Base model](https://github.com/binarybabel/latestver/blob/master/app/models/catalog_entry.rb) - Shows abstract functions and parsing helpers
* [RubyGem model](https://github.com/binarybabel/latestver/blob/master/app/models/catalog/ruby_gem.rb) - Good starting example
* [All other models](https://github.com/binarybabel/latestver/tree/master/app/models/catalog) - More advanced examples

Your model should be namespaced `module Catalog` and reside within your data volume in a `lib/catalog/` subdirectory.

## Contributing

1. Fork this repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -a -m 'Added some feature'`)
4. Push the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Author and License

 - **Author:** BinaryBabel OSS ([https://keybase.io/binarybabel](https://keybase.io/binarybabel))
 - **License:** GNU GPL 3

```
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
