{% from "nginx/map.jinja" import nginx with context %}

# Install the Nginx package
install_nginx:
  pkg.installed:
    - name: {{ nginx.pkg }}

# Manage the main Nginx configuration
manage_nginx_conf:
  file.managed:
    - name: {{ nginx.conf_file }}
    - source: {{ nginx.conf_source }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: install_nginx

# Ensure Nginx service is running and watches for config changes
run_nginx_service:
  service.running:
    - name: {{ nginx.service }}
    - enable: True
    - reload: True
    - watch:
      - file: manage_nginx_conf

{% if grains['os_family'] == 'Debian' %}
  {% set firewall_service = 'ufw' %}
{% elif grains['os_family'] == 'RedHat' %}
  {% set firewall_service = 'firewalld' %}
{% else %}
  {% set firewall_service = 'unknown' %}
{% endif %}

{% if firewall_service != 'unknown' %}
disable_firewall:
  service.dead:
    - name: {{ firewall_service }}
    - enable: False
{% else %}

warn_unsupported_os:
  test.show_notification:
    - text: "Firewall management not configured for {{ grains['os_family'] }}."
{% endif %}
