{% import 'macros.yml' as macros %}

{% set config = pillar['config'] %}
{% set is_uefi = grains['efi'] %}

{% if config.get('snapper', False) %}
include:
  {% if config.get('snapper', False) %}
  - storage.snapper.grub2-mkconfig
  {% endif %}
{% endif %}

{% if is_uefi %}
{{ macros.log('file', 'config_grub2_efi') }}
config_grub2_efi:
  file.append:
    - name: /mnt/etc/default/grub
    - text: GRUB_USE_LINUXEFI="true"
{% endif %}

{% if config.get('grub2_theme', False) %}
{{ macros.log('file', 'config_grub2_theme') }}
config_grub2_theme:
  file.append:
    - name: /mnt/etc/default/grub
    - text:
      - GRUB_TERMINAL="gfxterm"
      - GRUB_GFXMODE="auto"
      - GRUB_BACKGROUND=
      - GRUB_THEME="/boot/grub2/themes/openSUSE/theme.txt"
{% endif %}

{{ macros.log('file', 'config_grub2_resume') }}
config_grub2_resume:
  file.append:
    - name: /mnt/etc/default/grub
    - text:
      - GRUB_TIMEOUT=8
      - GRUB_DEFAULT="saved"
      - GRUB_SAVEDEFAULT="true"
      - GRUB_CMDLINE_LINUX_DEFAULT="splash=silent quiet"
      - GRUB_DISABLE_OS_PROBER="false"

{{ macros.log('file', 'grub2_mkconfig') }}
grub2_mkconfig:
  cmd.run:
    - name: grub2-mkconfig -o /boot/grub2/grub.cfg
    - root: /mnt
    - creates: /mnt/boot/grub2/grub.cfg
