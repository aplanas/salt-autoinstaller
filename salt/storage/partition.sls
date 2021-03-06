{% import 'macros.yml' as macros %}

{% set partitions = pillar['partitions'] %}
{% set is_uefi = grains['efi'] %}

{% set partition_config = partitions.get('config', {}) %}
{% set label = partition_config.get('label', 'msdos') %}
{% set is_uefi = grains['efi'] %}
{% for device, info in partitions.devices.items() %}

{{ macros.log('partitioned', 'create_disk_label_' ~ device) }}
create_disk_label_{{ device }}:
  partitioned.labeled:
    - name: {{ device }}
    - label: {{ info.label|default(label) }}

  {% set size_ns = namespace(end_size=partition_config.get('alignment', 1)) %}
  {% if label == 'gpt' and not is_uefi %}
{{ macros.log('partitioned', 'set_pmbr_boot_' ~ device) }}
set_pmbr_boot_{{ device }}:
  partitioned.disk_set:
    - name: {{ device }}
    - flag: pmbr_boot
    - enabled: True
  {% endif %}

  {% for partition in info.get('partitions', []) %}
    # TODO(aplanas) When moving it to Python, the partition number will be
    # deduced, so the require section in mkfs_partition will fail
    {% set device = device ~ info.get('number', loop.index) %}
{{ macros.log('partitioned', 'create_partition_' ~ device) }}
create_partition_{{ device }}:
  partitioned.mkparted:
    - name: {{ device }}
    # TODO(aplanas) If msdos we need to create extended and logical
    - part_type: primary
    - fs_type: {{ {'swap': 'linux-swap', 'linux': 'ext2', 'boot': 'ext2', 'efi': 'fat16'}[partition.type] }}
    - start: {{ size_ns.end_size }}MB
    - end: {{ size_ns.end_size + partition.size }}MB
    {% if label == 'gpt' and not is_uefi and partition.type == 'boot' %}
    - flags: [bios_grub]
    {% elif label == 'gpt' and is_uefi and partition.type == 'efi' %}
    - flags: [esp]
    {% endif %}
    {% set size_ns.end_size = size_ns.end_size + partition.size %}
  {% endfor %}
{% endfor %}
