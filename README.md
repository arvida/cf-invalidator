# cf-invalidator.rb

Simple tool to invalidate CloudFront paths. It's ruby based and uses the [fog gem](https://github.com/fog/fog).

## Usage

Invalidate a bunch of paths:

```$ cf-invalidator.rb -a ACCESS_KEY_ID -s SECRET_ACCESS_KEY -i CF_DISTRIBUTION_ID /assets/file-1.jpg /assets/file-2.jpg /assets/file-3.pdf```

Check what invalidation jobs exist:

```$ cf-invalidator.rb -a ACCESS_KEY_ID -s SECRET_ACCESS_KEY -i CF_DISTRIBUTION_ID```
