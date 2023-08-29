#! /bin/bash
#
# To run from HostsManager directory.
#


declare release_tag
declare release_note
declare release_dir=../hosts-manager
declare release_archive_name
declare github_repo="spo-ijaz/HostsManager"

function usage () {

    echo
    echo "Usage: "
    echo " .$0 <release_tag> \"<release note>\""
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

release_tag=$1
release_note=$2
release_archive_name="hosts-manager-${release}.src.tar.gz"

echo
echo "Create tag & push it..."
echo

# declare commit_id
# commit_id=$(git log --format="%H" -n 1)
# git tag -f "${release_tag}" "$commit_id"
# git push origin "${release_tag}" --force


echo
echo "Fetch code from github ( tag: ${release_tag} )..."
echo

git clone --depth 1 --branch ${release_tag} --single-branch https://github.com/spo-ijaz/HostsManager.git ${release_dir}



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

gh release create -t "HostsManager - v${release_tag}" --latest --repo ${github_repo} -n "${release_note}" ${release_tag}


echo
echo "Attach build asset..."
echo 

gh release upload --repo ${github_repo} ${release_tag} ../${release_archive_name}


echo 
echo "Cleanup..."
echo

rm -f ../${release_archive_name}
rm -f ../${release_dir}}