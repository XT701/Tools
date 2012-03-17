### Bash completion for the Android tools.

function _adb()
{
  local cur prev opts cmds c subcommand device_selected
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="-d -e -s -p"
  cmds="devices push pull sync shell emu logcat forward jdwp install \
        uninstall bugreport help version wait-for-device start-server \
        reboot reboot-bootloader \
        kill-server get-state get-serialno status-window remount root ppp"
  cmds_not_need_device="devices help version start-server kill-server"
  subcommand=""
  device_selected=""

  # Look for the subcommand.
  c=1
  while [ $c -lt $COMP_CWORD ]; do
    word="${COMP_WORDS[c]}"
    if [ "$word" = "-d" -o "$word" = "-e" -o "$word" = "-s" ]; then
      device_selected=true
      opts="-p"
    fi
    for cmd in $cmds; do
      if [ "$cmd" = "$word" ]; then
        subcommand="$word"
      fi
    done
    c=$((++c))
  done

  case "${subcommand}" in
    '')
      case "${prev}" in
        -p)
          return 0;
          ;;
        -s)
          # Use 'adb devices' to list serial numbers.
          COMPREPLY=( $(compgen -W "$(adb devices|grep 'device$'|cut -f1)" -- ${cur} ) )
          return 0
          ;;
      esac
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
          return 0
          ;;
      esac
      if [ -z "$device_selected" ]; then
        local num_devices=$(( $(adb devices 2>/dev/null|wc -l) - 2 ))
        if [ "$num_devices" -gt "1" ]; then
          # With multiple devices, you must choose a device first.
          COMPREPLY=( $(compgen -W "${opts} ${cmds_not_need_device}" -- ${cur}) )
          return 0
        fi
      fi
      COMPREPLY=( $(compgen -W "${cmds}" -- ${cur}) )
      return 0
      ;;
    install)
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "-l -r -s" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
    forward)
      # Filename or installation option.
      COMPREPLY=( $(compgen -W "tcp: localabstract: localreserved: localfilesystem: dev: jdwp:" -- ${cur}) )
      return 0
      ;;
    uninstall)
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "-k" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
    logcat)
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "-v -b -c -d -f -g -n -r -s" -- ${cur}) )
          return 0
          ;;
      esac
      case "${prev}" in
        -v)
          COMPREPLY=( $(compgen -W "brief process tag thread raw time long" -- ${cur}) )
          return 0
          ;;
        -b)
          COMPREPLY=( $(compgen -W "radio events main" -- ${cur}) )
          return 0
          ;;
      esac
      ;;
  esac
}
complete -o default -F _adb adb

function _fastboot()
{
  local cur prev opts cmds c subcommand device_selected
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="-w -s -p -c -i -b -n"
  cmds="update flashall flash erase getvar boot devices \
        reboot reboot-bootloader oem"
  subcommand=""
  partition_list="boot recovery system userdata"
  device_selected=""

  # Look for the subcommand.
  c=1
  while [ $c -lt $COMP_CWORD ]; do
    word="${COMP_WORDS[c]}"
    if [ "$word" = "-s" ]; then
      device_selected=true
    fi
    for cmd in $cmds; do
      if [ "$cmd" = "$word" ]; then
        subcommand="$word"
      fi
    done
    c=$((++c))
  done

  case "${subcommand}" in
    '')
      case "${prev}" in
        -s)
          # Use 'fastboot devices' to list serial numbers.
          COMPREPLY=( $(compgen -W "$(fastboot devices|cut -f1)" -- ${cur} ) )
          return 0
          ;;
      esac
      case "${cur}" in
        -*)
          COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
          return 0
          ;;
      esac
      if [ -z "$device_selected" ]; then
        local num_devices=$(( $(fastboot devices 2>/dev/null|wc -l) ))
        if [ "$num_devices" -gt "1" ]; then
          # With multiple devices, you must choose a device first.
          COMPREPLY=( $(compgen -W "-s" -- ${cur}) )
          return 0
        fi
      fi
      COMPREPLY=( $(compgen -W "${cmds}" -- ${cur}) )
      return 0
      ;;
    flash)
      # partition name
      COMPREPLY=( $(compgen -W "${partition_list}" -- ${cur}) )
      return 0
      ;;
    erase)
      # partition name
      COMPREPLY=( $(compgen -W "${partition_list}" -- ${cur}) )
      return 0
      ;;
  esac
}
complete -o default -F _fastboot fastboot
