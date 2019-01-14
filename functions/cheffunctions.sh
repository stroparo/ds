# Chef support functions

chef-up-changelog () {

  typeset cookbook_version=$(grep "^version " metadata.rb | cut -d"'" -f2)
  typeset message="$1"

  mv -f -v CHANGELOG.md CHANGELOG.md.orig

  tee CHANGELOG.md <<EOF
${cookbook_version}
$(echo "$cookbook_version" | tr '[[:print:]]' '-')
- ${message}

EOF

  cat >> CHANGELOG.md < CHANGELOG.md.orig \
    && rm -f -v CHANGELOG.md.orig
}

chef-up-version-minor () {

  typeset cookbook_version=$(grep "^version " metadata.rb | cut -d"'" -f2)
  typeset minor_version=$(echo "$cookbook_version" | awk -F. '{print $NF;}')

  minor_version=$((minor_version+1))
  sed -i -e "/^version.*/s/[.][0-9]*\(['\"] *\)$/.${minor_version}\\1/" metadata.rb
}
