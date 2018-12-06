{% set config = pillar['config'] %}

include:
  - .device.mount
  - .btrfs.mount
{% if config.get('snapper', False) %}
  - .snapper.mount
{% endif %}
