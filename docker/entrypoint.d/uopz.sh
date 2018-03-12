PHP_EXTENSION_INI_FILE=/usr/local/etc/php/conf.d/docker-php-ext-uopz.ini
if [[ -f $PHP_EXTENSION_INI_FILE ]]; then
    return
fi

(
cat <<INI
[uopz]
extension=$(php-config --extension-dir)/uopz.so

INI
) | grep -v -E '=$' | tee $PHP_EXTENSION_INI_FILE >/dev/null
