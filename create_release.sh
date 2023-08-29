#! /bin/bash
#
# To run from HostsManager directory.
#


declare release
declare release_note
declare release_dir=../hosts-manager
declare release_archive_name
declare github_repo="spo-ijaz/HostsManager"

function usage () {

    echo "Usage: "
    echo " .$0 <release_version> \"<release note>\""
    exit 0  
}

if [[ -z $1  ]]; then
    echo "Missing release tag."
    usage
fi

if [[ -z $2  ]]; then
    echo "Missing release note."
    usage
fi

release=$1
release_note=$2
release_archive_name="hosts-manager-${release}.src.tar.gz"

echo
echo "Create tag & push it..."
echo

# declare commit_id
# commit_id=$(git log --format="%H" -n 1)
# git tag -f "${release}" "$3"
# git push origin "${release}" --force


echo
echo "Fetch code from github ( tag: ${release} )..."
echo

# git clone --depth 1 --branch ${release} --single-branch https://github.com/spo-ijaz/HostsManager.git ${release_dir}



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
gh release create -p -t "HostsManager - v${release}" --latest --repo ${github_repo} -n "${release_note}" ${release}

echo
echo "Attach build asset..."
echo 
gh release upload --repo ${github_repo} ${version} ../${release_archive_name}