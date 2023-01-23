# Java Dapr-AKS-ACA Workshop Documentation

## Generate locally

To generate the documentation locally, [Ruby](https://www.ruby-lang.org/) and [Ruby Gems](https://rubygems.org/) are required.

Jekyll and Bundler are required to generate the documentation locally. To [install](https://jekyllrb.com/docs/installation/) them, run the following commands:

```bash
gem install jekyll bundler
```

To run a local server, run the following command:

```bash
bundle install
bundle exec jekyll serve --config _config.local.yml
```
