{% import 'macros.yml' as macros %}

{% set filesystems = pillar['filesystems'] %}

{% for device, info in filesystems.items() %}
{{ macros.log('formatted', 'mkfs_partition_' ~ device) }}
mkfs_partition_{{ device }}:
  formatted.formatted:
    - name: {{ device }}
    - fs_type: {{ info.filesystem }}
  {% if info.filesystem in ('fat', 'vfat') and info.get('fat') %}
    - fat: {{ info.fat }}
  {% endif %}
    - require:
      - partitioned: create_partition_{{ device }}
{% endfor %}
