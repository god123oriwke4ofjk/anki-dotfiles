#!/usr/bin/env bash
# Updates wallbash.json, merges colors into meta.json, and logs details
json_file="${HOME}/.local/share/Anki2/addons21/688199788/themes/wallbash.json"
meta_json="${HOME}/.local/share/Anki2/addons21/688199788/meta.json"
prefs_db="${HOME}/.local/share/Anki2/User 1/prefs21.db"
cache_dir="${HOME}/.cache/hyde/wallbash"
colors_conf="${HOME}/.config/hypr/themes/colors.conf"
mkdir -p "${cache_dir}"

if [[ -f "${json_file}" ]]; then
  cp "${json_file}" "${cache_dir}/anki-wallbash.json"
  echo "Anki ReColor theme updated with Wallbash colors: ${json_file}"
  echo "JSON content:" >> "${cache_dir}/anki-wallbash.log"
  cat "${json_file}" >> "${cache_dir}/anki-wallbash.log"

  # Merge wallbash.json colors into meta.json
  if [[ -f "${meta_json}" ]] && command -v jq >/dev/null 2>&1; then
    jq --argjson new_colors "$(jq .colors "${json_file}")" \
       '.config.colors |= ($new_colors + .config.colors)' "${meta_json}" > "${cache_dir}/meta.json.tmp" && \
       mv "${cache_dir}/meta.json.tmp" "${meta_json}"
    echo "Merged wallbash.json colors into meta.json" >> "${cache_dir}/anki-wallbash.log"
  else
    echo "Warning: meta.json not found or jq not installed, cannot update colors" >> "${cache_dir}/anki-wallbash.log"
  fi

  # Update prefs21.db to ensure wallbash is selected
  if [[ -f "${prefs_db}" ]] && command -v sqlite3 >/dev/null 2>&1; then
    sqlite3 "${prefs_db}" "INSERT OR IGNORE INTO prefs (key, value) VALUES ('add-ons', '{}');"
    sqlite3 "${prefs_db}" "UPDATE prefs SET value = json_set(value, '$.688199788.theme', 'wallbash') WHERE key = 'add-ons';"
    echo "Updated prefs21.db to set ReColor theme: wallbash" >> "${cache_dir}/anki-wallbash.log"
  else
    echo "Warning: prefs21.db not found or sqlite3 not installed, cannot update theme" >> "${cache_dir}/anki-wallbash.log"
  fi

  # Log colors.conf
  echo "colors.conf content:" >> "${cache_dir}/anki-wallbash.log"
  if [[ -f "${colors_conf}" ]]; then
    cat "${colors_conf}" >> "${cache_dir}/anki-wallbash.log"
  else
    echo "colors.conf not found at ${colors_conf}" >> "${cache_dir}/anki-wallbash.log"
  fi

  # Validate JSON
  if command -v jq >/dev/null 2>&1; then
    if jq . "${json_file}" >/dev/null 2>&1; then
      echo "JSON is valid" >> "${cache_dir}/anki-wallbash.log"
    else
      echo "Error: Invalid JSON in ${json_file}" >> "${cache_dir}/anki-wallbash.log"
    fi
    if jq . "${meta_json}" >/dev/null 2>&1; then
      echo "meta.json is valid" >> "${cache_dir}/anki-wallbash.log"
    else
      echo "Error: Invalid JSON in ${meta_json}" >> "${cache_dir}/anki-wallbash.log"
    fi
  else
    echo "jq not installed, skipping JSON validation" >> "${cache_dir}/anki-wallbash.log"
  fi
else
  echo "Error: Anki ReColor JSON file not found at ${json_file}"
  echo "Error: Check Wallbash execution, permissions, or anki.dcol syntax" >> "${cache_dir}/anki-wallbash.log"
fi
