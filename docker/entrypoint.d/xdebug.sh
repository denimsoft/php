PHP_EXTENSION_INI_FILE=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
if [[ -f $PHP_EXTENSION_INI_FILE ]]; then
    return
fi

(
cat <<INI
[xdebug]
zend_extension=$(php-config --extension-dir)/xdebug.so
xdebug.auto_trace=$XDEBUG_AUTO_TRACE
xdebug.cli_color=${XDEBUG_CLI_COLOR:-1}
xdebug.collect_assignments=$XDEBUG_COLLECT_ASSIGNMENTS
xdebug.collect_includes=$XDEBUG_COLLECT_INCLUDES
xdebug.collect_params=$XDEBUG_COLLECT_PARAMS
xdebug.collect_return=$XDEBUG_COLLECT_RETURN
xdebug.collect_vars=$XDEBUG_COLLECT_VARS
xdebug.coverage_enable=$XDEBUG_COVERAGE_ENABLE
xdebug.default_enable=$XDEBUG_DEFAULT_ENABLE
xdebug.dump.COOKIE=$XDEBUG_DUMP_COOKIE
xdebug.dump.ENV=$XDEBUG_DUMP_ENV
xdebug.dump.FILES=$XDEBUG_DUMP_FILES
xdebug.dump.GET=$XDEBUG_DUMP_GET
xdebug.dump.POST=$XDEBUG_DUMP_POST
xdebug.dump.REQUEST=$XDEBUG_DUMP_REQUEST
xdebug.dump.SERVER=$XDEBUG_DUMP_SERVER
xdebug.dump.SESSION=$XDEBUG_DUMP_SESSION
xdebug.dump_globals=$XDEBUG_DUMP_GLOBALS
xdebug.dump_once=$XDEBUG_DUMP_ONCE
xdebug.dump_undefined=$XDEBUG_DUMP_UNDEFINED
xdebug.extended_info=$XDEBUG_EXTENDED_INFO
xdebug.file_link_format=$XDEBUG_FILE_LINK_FORMAT
xdebug.force_display_errors=$XDEBUG_FORCE_DISPLAY_ERRORS
xdebug.force_error_reporting=$XDEBUG_FORCE_ERROR_REPORTING
xdebug.halt_level=$XDEBUG_HALT_LEVEL
xdebug.idekey=$XDEBUG_IDEKEY
xdebug.max_nesting_level=$XDEBUG_MAX_NESTING_LEVEL
xdebug.max_stack_frames=$XDEBUG_MAX_STACK_FRAMES
xdebug.overload_var_dump=$XDEBUG_OVERLOAD_VAR_DUMP
xdebug.profiler_aggregate=$XDEBUG_PROFILER_AGGREGATE
xdebug.profiler_append=$XDEBUG_PROFILER_APPEND
xdebug.profiler_enable=$XDEBUG_PROFILER_ENABLE
xdebug.profiler_enable_trigger=${XDEBUG_PROFILER_ENABLE_TRIGGER:-1}
xdebug.profiler_enable_trigger_value=$XDEBUG_PROFILER_ENABLE_TRIGGER_VALUE
xdebug.profiler_output_dir=$XDEBUG_PROFILER_OUTPUT_DIR
xdebug.profiler_output_name=${XDEBUG_PROFILER_OUTPUT_NAME:-cachegrind.%H.%u}
xdebug.remote_addr_header=$XDEBUG_REMOTE_ADDR_HEADER
xdebug.remote_autostart=$XDEBUG_REMOTE_AUTOSTART
xdebug.remote_connect_back=$XDEBUG_REMOTE_CONNECT_BACK
xdebug.remote_cookie_expire_time=$XDEBUG_REMOTE_COOKIE_EXPIRE_TIME
xdebug.remote_enable=${XDEBUG_REMOTE_ENABLE:-1}
xdebug.remote_handler=$XDEBUG_REMOTE_HANDLER
xdebug.remote_host=${XDEBUG_REMOTE_HOST:-docker.for.mac.localhost}
xdebug.remote_log=$XDEBUG_REMOTE_LOG
xdebug.remote_mode=$XDEBUG_REMOTE_MODE
xdebug.remote_port=$XDEBUG_REMOTE_PORT
xdebug.scream=$XDEBUG_SCREAM
xdebug.show_error_trace=$XDEBUG_SHOW_ERROR_TRACE
xdebug.show_exception_trace=$XDEBUG_SHOW_EXCEPTION_TRACE
xdebug.show_local_vars=$XDEBUG_SHOW_LOCAL_VARS
xdebug.show_mem_delta=$XDEBUG_SHOW_MEM_DELTA
xdebug.trace_enable_trigger=${XDEBUG_TRACE_ENABLE_TRIGGER:-1}
xdebug.trace_enable_trigger_value=$XDEBUG_TRACE_ENABLE_TRIGGER_VALUE
xdebug.trace_format=$XDEBUG_TRACE_FORMAT
xdebug.trace_options=$XDEBUG_TRACE_OPTIONS
xdebug.trace_output_dir=$XDEBUG_TRACE_OUTPUT_DIR
xdebug.trace_output_name=${XDEBUG_TRACE_OUTPUT_NAME:-trace.%H.%u}
xdebug.var_display_max_children=$XDEBUG_VAR_DISPLAY_MAX_CHILDREN
xdebug.var_display_max_data=$XDEBUG_VAR_DISPLAY_MAX_DATA
xdebug.var_display_max_depth=$XDEBUG_VAR_DISPLAY_MAX_DEPTH

INI
) | grep -v -E '=$' | tee $PHP_EXTENSION_INI_FILE >/dev/null
