#! /bin/bash
#
# To run from HostsManager directory.
#


declare release_tag
declare release_note_file
declare release_dir=../hosts-manager
declare release_archive_name
declare github_repo="spo-ijaz/HostsManager"

declare fedora_spec=./fedora/hostsmanager.spec
declare meson_build=./meson.build

function usage () {

    echo
    echo "Usage: "
    echo " .$0 <release_tag> \"<path to release note file>\""
    exit 0
}

if [[ -z $1  ]]; then
    echo "Missing release tag."
    usage
fi

if [[ ! -f $2  ]]; then
    echo "Missing release note file."
    usage
fi

release_tag=$1
release_note_file=$2
release_archive_name="hosts-manager-${release}.src.tar.gz"

echo
echo "Update Fedora spec file..."
echo

sed -i "s/\(Version:.*\)[0-9]\.[0-9]\.[0-9]/\1${release_tag}/g" "${fedora_spec}"

echo
echo "Update meson.build..."
echo

sed -i "s/\(version:.*\)'[0-9]\.[0-9]\.[0-9]'/\1'${release_tag}'/g" "${meson_build}"

echo
echo "Commit & push changes..."
echo

git add "${fedora_spec}" "${meson_build}"
git commit -m "Version bump to ${release_tag}"
git push origin master


echo
echo "Create tag & push it..."
echo

declare commit_id
commit_id=$(git log --format="%H" -n 1)
git tag -f "${release_tag}" "$commit_id"
git push origin "${release_tag}" --force



echo
echo "Fetch code from gitlab ( tag: ${release_tag} )..."
echo

git clone --depth 1 --branch ${release_tag} --single-branch https://gitlab.gnome.org/spo-ijaz/HostsManager.git ${release_dir}



echo
echo "Create archive..."
echo

[[ -f ../${release_archive_name} ]] && rm -f ../${release_archive_name}
tar -czvf ../${release_archive_name} \
    -C "${release_dir}" \
    --exclude="**/build" \
    --exclude="**/settings-json" \
    --exclude="**/.idea" \
    --exclude="**/.vscode"  \
    .


echo
echo "Create a new release..."
echo

# For pre-release
#gh release create -p -t "HostsManager - v${release_tag}" --latest --repo ${github_repo} -n "${release_note}" ${release_tag}
#gh release create -t "HostsManager - v${release_tag}" --latest --repo ${github_repo} -F "${release_note_file}" ${release_tag}


echo
echo "Attach build asset..."
echo

#gh release upload --repo ${github_repo} ${release_tag} ../${release_archive_name}


echo
echo "Cleanup..."
echo

rm -f ../${release_archive_name}
rm -f ../${release_dir}}
