---
title: Improve this Site
permalink: /contribute/
toc: true
sidebar:
    nav: "v1guides"

---

## Video Walkthrough of a Change
{% include youtube.html id="qRfXGot0eMA" %}

## Introduction

Thank you for improving this site! This site is open source and the API maintainers welcome your contributions. [Please reach out](/help/) if you have any questions. Minor changes may be made directly in GitHub's online editor wherever &nbsp;<i class="fas fa-edit" aria-hidden="true"></i>&nbsp;**Edit**&nbsp; appears at bottom-right. 

Changes are published automatically by GitHub pages when merged to branch "main". When sending a pull request it's necessary to change the base repo to "netfoundry/mop-api-docs" to avoid sending the request to the upstream forked theme repo.

## Content

The content of this site lives in the top-level directory `/docs` in the GitHub repo [netfoundry/mop-api-docs](https://github.com/netfoundry/mop-api-docs/tree/main/docs). Most of the content is in `/docs/_pages/` with meaningful names. You can add or edit Kramdown (GitHub-flavored Markdown) `.md`, `.markdown`; or Liquid template `.html` files.

## Theme

The theme lives in the top-level `/` in the same GitHub repo as the content: [netfoundry/mop-api-docs](https://github.com/netfoundry/mop-api-docs). The repo is forked from Minimal Mistakes v4.19.2 which publishes an excellent [quick-start guide](https://mmistakes.github.io/minimal-mistakes/docs/overriding-theme-defaults/). The idea is to override theme defaults in the content area `/docs` in order to minimize changes to the upstream theme.

For example, `/docs/_layouts/default.html` overrides `/_layouts/default.html` and is available immediately in the local preview. Changes to the default, inherited theme files don't become visible in the local preview until they're merged to the main branch in the Git remote. Most changes should be overrides under `/docs`.

## Preview

These steps provide a local preview server at **[http://localhost:4000/](http://localhost:4000/)**

1. Install
    1. [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), 
    2. [Docker Engine](https://docs.docker.com/engine/install/), and 
    3. [Docker Compose](https://docs.docker.com/compose/install/)
2. clone the repo 

    ```bash
    git clone git@github.com:netfoundry/mop-api-docs.git
    ```

3. switch to the content area `/docs` in the cloned working copy

    ```bash
    cd ./mop-api-docs/docs
    ```

4. execute

    ```bash
    docker-compose up --build preview
    ```

5. **browse to [http://localhost:4000/](http://localhost:4000/)**

6. Be aware that *search is not available* in the local preview.
7. Stop the preview container
    1. Focus the terminal where the container is running
    2. Send a `SIGTERM`, typically `Ctrl-c`
    
8. Alternatively, you could 
    1. run the preview container in the background
        
        ```bash
        docker-compose up --build --detach preview
        ``` 

    2. and later stop the preview container

        ```bash
        docker-compose down --remove-orphans
        ```

### Things to Know

* Local changes to files in `/docs` will be picked up immediately by Jekyll, except `/docs/_config.yml` which requires restarting the preview container.
* Optionally, before running the container, export your [GitHub API token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) as `JEKYLL_GITHUB_TOKEN` and it will be made available to Jekyll for querying metadata from the GitHub API.

## GitHub Workflow

1. fork the repo, unless you have access to main repo
2. clone the repo
3. make a change
4. create a local branch
5. commit your change
6. push your commit to the remote
7. create a pull request for your branch
8. change the base repo to "netfoundry/mop-api-docs" 
9. submit your pull request
10. monitor for build failures

## CI/CD

* All merges to the main branch are automatically published by GitHub pages.
* Pushes to main will also trigger [a Github Action](https://github.com/netfoundry/mop-api-docs/actions/workflows/update-algolia.yml). The Github Action:
    * validates the changes with Jekyll
    * updates the Algolia search index. A Github secret is named `ALGOLIA_API_KEY` needs to be set for the Algolia step to pass and is defined in the Netfoundry Github Organization.
* The GitHub repo has branch protections for main that require successful Github actions before allowing the merge as well as a PR approval from another user.
* The domain name developer.netfoundry.io is a `CNAME` resource record in the netfoundry.io hosted zone in Route53. The `RDATA` of the record is the GitHub Pages sub-domain.
    ```bash
    ❯ dig +short -tCNAME developer.netfoundry.io.
    netfoundry.github.io.
    ```
