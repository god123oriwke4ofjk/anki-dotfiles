#!/usr/bin/env bash
# Updates wallbash.json and merges colors into meta.json
json_file="${HOME}/.local/share/Anki2/addons21/688199788/themes/wallbash.json"
meta_json="${HOME}/.local/share/Anki2/addons21/688199788/meta.json"
prefs_db="${HOME}/.local/share/Anki2/User 1/prefs21.db"
cache_dir="${HOME}/.cache/hyde/wallbash"
colors_conf="${HOME}/.config/hypr/themes/colors.conf"
mkdir -p "${cache_dir}"

if [[ -f "${json_file}" ]]; then
  cp "${json_file}" "${cache_dir}/anki-wallbash.json"

  # Merge wallbash.json colors into meta.json
  if [[ -f "${meta_json}" ]] && command -v jq >/dev/null 2>&1; then
    jq --argjson new_colors "$(jq .colors "${json_file}")" \
       '.config.colors |= ($new_colors + .config.colors)' "${meta_json}" > "${cache_dir}/meta.json.tmp" && \
       mv "${cache_dir}/meta.json.tmp" "${meta_json}"
  fi

  # Update prefs21.db to ensure wallbash is selected
  if [[ -f "${prefs_db}" ]] && command -v sqlite3 >/dev/null 2>&1; then
    sqlite3 "${prefs_db}" "INSERT OR IGNORE INTO prefs (key, value) VALUES ('add-ons', '{}');"
    sqlite3 "${prefs_db}" "UPDATE prefs SET value = json_set(value, '$.688199788.theme', 'wallbash') WHERE key = 'add-ons';"
  fi
fi
