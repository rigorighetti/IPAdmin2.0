




<!DOCTYPE html>
<html class="   ">
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# object: http://ogp.me/ns/object# article: http://ogp.me/ns/article# profile: http://ogp.me/ns/profile#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    
    
    <title>Plugins/integration/jqueryui/dataTables.jqueryui.js at master · DataTables/Plugins · GitHub</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png" />
    <meta property="fb:app_id" content="1401488693436528"/>

      <meta content="@github" name="twitter:site" /><meta content="summary" name="twitter:card" /><meta content="DataTables/Plugins" name="twitter:title" /><meta content="Plugins - Plug-ins for DataTables" name="twitter:description" /><meta content="https://avatars2.githubusercontent.com/u/278219?s=400" name="twitter:image:src" />
<meta content="GitHub" property="og:site_name" /><meta content="object" property="og:type" /><meta content="https://avatars2.githubusercontent.com/u/278219?s=400" property="og:image" /><meta content="DataTables/Plugins" property="og:title" /><meta content="https://github.com/DataTables/Plugins" property="og:url" /><meta content="Plugins - Plug-ins for DataTables" property="og:description" />

    <link rel="assets" href="https://assets-cdn.github.com/">
    <link rel="conduit-xhr" href="https://ghconduit.com:25035">
    

    <meta name="msapplication-TileImage" content="/windows-tile.png" />
    <meta name="msapplication-TileColor" content="#ffffff" />
    <meta name="selected-link" value="repo_source" data-pjax-transient />
      <meta name="google-analytics" content="UA-3769691-2">

    <meta content="collector.githubapp.com" name="octolytics-host" /><meta content="collector-cdn.github.com" name="octolytics-script-host" /><meta content="github" name="octolytics-app-id" /><meta content="5D3FFE24:01FD:12E71E41:53A8393E" name="octolytics-dimension-request_id" />
    

    
    
    <link rel="icon" type="image/x-icon" href="https://assets-cdn.github.com/favicon.ico" />


    <meta content="authenticity_token" name="csrf-param" />
<meta content="jqobgrLQVNzqbGwltVoiJeBbPSJima0+AV2y9S2CvL5NHKkXzLv1kIghgG4jg6K1aOW9XwDzHJGXfcbZRIPmQQ==" name="csrf-token" />

    <link href="https://assets-cdn.github.com/assets/github-eb5c3c423cbc57fa389bbe6f9a4bb3a6ce0cf4cf.css" media="all" rel="stylesheet" type="text/css" />
    <link href="https://assets-cdn.github.com/assets/github2-17623a85ccf3de21ab65566d4a60a8dc5db55168.css" media="all" rel="stylesheet" type="text/css" />
    


    <meta http-equiv="x-pjax-version" content="e977bc197a54cd5b202e0152ad03012e">

      
  <meta name="description" content="Plugins - Plug-ins for DataTables" />


  <meta content="278219" name="octolytics-dimension-user_id" /><meta content="DataTables" name="octolytics-dimension-user_login" /><meta content="4505588" name="octolytics-dimension-repository_id" /><meta content="DataTables/Plugins" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="false" name="octolytics-dimension-repository_is_fork" /><meta content="4505588" name="octolytics-dimension-repository_network_root_id" /><meta content="DataTables/Plugins" name="octolytics-dimension-repository_network_root_nwo" />
  <link href="https://github.com/DataTables/Plugins/commits/master.atom" rel="alternate" title="Recent Commits to Plugins:master" type="application/atom+xml" />

  </head>


  <body class="logged_out  env-production linux vis-public page-blob">
    <a href="#start-of-content" tabindex="1" class="accessibility-aid js-skip-to-content">Skip to content</a>
    <div class="wrapper">
      
      
      
      


      
      <div class="header header-logged-out">
  <div class="container clearfix">

    <a class="header-logo-wordmark" href="https://github.com/">
      <span class="mega-octicon octicon-logo-github"></span>
    </a>

    <div class="header-actions">
        <a class="button primary" href="/join">Sign up</a>
      <a class="button signin" href="/login?return_to=%2FDataTables%2FPlugins%2Fblob%2Fmaster%2Fintegration%2Fjqueryui%2FdataTables.jqueryui.js">Sign in</a>
    </div>

    <div class="command-bar js-command-bar  in-repository">

      <ul class="top-nav">
          <li class="explore"><a href="/explore">Explore</a></li>
        <li class="features"><a href="/features">Features</a></li>
          <li class="enterprise"><a href="https://enterprise.github.com/">Enterprise</a></li>
          <li class="blog"><a href="/blog">Blog</a></li>
      </ul>
        <form accept-charset="UTF-8" action="/search" class="command-bar-form" id="top_search_form" method="get">

<div class="commandbar">
  <span class="message"></span>
  <input type="text" data-hotkey="s" name="q" id="js-command-bar-field" placeholder="Search or type a command" tabindex="1" autocapitalize="off"
    
    
      data-repo="DataTables/Plugins"
      data-branch="master"
      data-sha="56d8a979ba9c11c34eed96bb020a4cf1c95327f3"
  >
  <div class="display hidden"></div>
</div>

    <input type="hidden" name="nwo" value="DataTables/Plugins" />

    <div class="select-menu js-menu-container js-select-menu search-context-select-menu">
      <span class="minibutton select-menu-button js-menu-target" role="button" aria-haspopup="true">
        <span class="js-select-button">This repository</span>
      </span>

      <div class="select-menu-modal-holder js-menu-content js-navigation-container" aria-hidden="true">
        <div class="select-menu-modal">

          <div class="select-menu-item js-navigation-item js-this-repository-navigation-item selected">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" class="js-search-this-repository" name="search_target" value="repository" checked="checked" />
            <div class="select-menu-item-text js-select-button-text">This repository</div>
          </div> <!-- /.select-menu-item -->

          <div class="select-menu-item js-navigation-item js-all-repositories-navigation-item">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" name="search_target" value="global" />
            <div class="select-menu-item-text js-select-button-text">All repositories</div>
          </div> <!-- /.select-menu-item -->

        </div>
      </div>
    </div>

  <span class="help tooltipped tooltipped-s" aria-label="Show command bar help">
    <span class="octicon octicon-question"></span>
  </span>


  <input type="hidden" name="ref" value="cmdform">

</form>
    </div>

  </div>
</div>



      <div id="start-of-content" class="accessibility-aid"></div>
          <div class="site" itemscope itemtype="http://schema.org/WebPage">
    <div id="js-flash-container">
      
    </div>
    <div class="pagehead repohead instapaper_ignore readability-menu">
      <div class="container">
        

<ul class="pagehead-actions">


  <li>
      <a href="/login?return_to=%2FDataTables%2FPlugins"
    class="minibutton with-count star-button tooltipped tooltipped-n"
    aria-label="You must be signed in to star a repository" rel="nofollow">
    <span class="octicon octicon-star"></span>
    Star
  </a>

    <a class="social-count js-social-count" href="/DataTables/Plugins/stargazers">
      220
    </a>

  </li>

    <li>
      <a href="/login?return_to=%2FDataTables%2FPlugins"
        class="minibutton with-count js-toggler-target fork-button tooltipped tooltipped-n"
        aria-label="You must be signed in to fork a repository" rel="nofollow">
        <span class="octicon octicon-repo-forked"></span>
        Fork
      </a>
      <a href="/DataTables/Plugins/network" class="social-count">
        451
      </a>
    </li>
</ul>

        <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public">
          <span class="repo-label"><span>public</span></span>
          <span class="mega-octicon octicon-repo"></span>
          <span class="author"><a href="/DataTables" class="url fn" itemprop="url" rel="author"><span itemprop="title">DataTables</span></a></span><!--
       --><span class="path-divider">/</span><!--
       --><strong><a href="/DataTables/Plugins" class="js-current-repository js-repo-home-link">Plugins</a></strong>

          <span class="page-context-loader">
            <img alt="" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
          </span>

        </h1>
      </div><!-- /.container -->
    </div><!-- /.repohead -->

    <div class="container">
      <div class="repository-with-sidebar repo-container new-discussion-timeline js-new-discussion-timeline  ">
        <div class="repository-sidebar clearfix">
            

<div class="sunken-menu vertical-right repo-nav js-repo-nav js-repository-container-pjax js-octicon-loaders">
  <div class="sunken-menu-contents">
    <ul class="sunken-menu-group">
      <li class="tooltipped tooltipped-w" aria-label="Code">
        <a href="/DataTables/Plugins" aria-label="Code" class="selected js-selected-navigation-item sunken-menu-item" data-hotkey="g c" data-pjax="true" data-selected-links="repo_source repo_downloads repo_commits repo_releases repo_tags repo_branches /DataTables/Plugins">
          <span class="octicon octicon-code"></span> <span class="full-word">Code</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

        <li class="tooltipped tooltipped-w" aria-label="Issues">
          <a href="/DataTables/Plugins/issues" aria-label="Issues" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-hotkey="g i" data-selected-links="repo_issues /DataTables/Plugins/issues">
            <span class="octicon octicon-issue-opened"></span> <span class="full-word">Issues</span>
            <span class='counter'>17</span>
            <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>        </li>

      <li class="tooltipped tooltipped-w" aria-label="Pull Requests">
        <a href="/DataTables/Plugins/pulls" aria-label="Pull Requests" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-hotkey="g p" data-selected-links="repo_pulls /DataTables/Plugins/pulls">
            <span class="octicon octicon-git-pull-request"></span> <span class="full-word">Pull Requests</span>
            <span class='counter'>6</span>
            <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>


    </ul>
    <div class="sunken-menu-separator"></div>
    <ul class="sunken-menu-group">

      <li class="tooltipped tooltipped-w" aria-label="Pulse">
        <a href="/DataTables/Plugins/pulse" aria-label="Pulse" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="pulse /DataTables/Plugins/pulse">
          <span class="octicon octicon-pulse"></span> <span class="full-word">Pulse</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped tooltipped-w" aria-label="Graphs">
        <a href="/DataTables/Plugins/graphs" aria-label="Graphs" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="repo_graphs repo_contributors /DataTables/Plugins/graphs">
          <span class="octicon octicon-graph"></span> <span class="full-word">Graphs</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped tooltipped-w" aria-label="Network">
        <a href="/DataTables/Plugins/network" aria-label="Network" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-selected-links="repo_network /DataTables/Plugins/network">
          <span class="octicon octicon-repo-forked"></span> <span class="full-word">Network</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>
    </ul>


  </div>
</div>

              <div class="only-with-full-nav">
                

  

<div class="clone-url open"
  data-protocol-type="http"
  data-url="/users/set_protocol?protocol_selector=http&amp;protocol_type=clone">
  <h3><strong>HTTPS</strong> clone URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/DataTables/Plugins.git" readonly="readonly">
    <span class="url-box-clippy">
    <button aria-label="copy to clipboard" class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="https://github.com/DataTables/Plugins.git" data-copied-hint="copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>

  

<div class="clone-url "
  data-protocol-type="subversion"
  data-url="/users/set_protocol?protocol_selector=subversion&amp;protocol_type=clone">
  <h3><strong>Subversion</strong> checkout URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/DataTables/Plugins" readonly="readonly">
    <span class="url-box-clippy">
    <button aria-label="copy to clipboard" class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="https://github.com/DataTables/Plugins" data-copied-hint="copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>


<p class="clone-options">You can clone with
      <a href="#" class="js-clone-selector" data-protocol="http">HTTPS</a>
      or <a href="#" class="js-clone-selector" data-protocol="subversion">Subversion</a>.
  <a href="https://help.github.com/articles/which-remote-url-should-i-use" class="help tooltipped tooltipped-n" aria-label="Get help on which URL is right for you.">
    <span class="octicon octicon-question"></span>
  </a>
</p>



                <a href="/DataTables/Plugins/archive/master.zip"
                   class="minibutton sidebar-button"
                   aria-label="Download DataTables/Plugins as a zip file"
                   title="Download DataTables/Plugins as a zip file"
                   rel="nofollow">
                  <span class="octicon octicon-cloud-download"></span>
                  Download ZIP
                </a>
              </div>
        </div><!-- /.repository-sidebar -->

        <div id="js-repo-pjax-container" class="repository-content context-loader-container" data-pjax-container>
          


<a href="/DataTables/Plugins/blob/b644af9c803f81a6d6397c3f06e8ef02acfd1aea/integration/jqueryui/dataTables.jqueryui.js" class="hidden js-permalink-shortcut" data-hotkey="y">Permalink</a>

<!-- blob contrib key: blob_contributors:v21:ccf2bfcc604c532d61d8dcafec722d7e -->

<p title="This is a placeholder element" class="js-history-link-replace hidden"></p>

<div class="file-navigation">
  

<div class="select-menu js-menu-container js-select-menu" >
  <span class="minibutton select-menu-button js-menu-target css-truncate" data-hotkey="w"
    data-master-branch="master"
    data-ref="master"
    title="master"
    role="button" aria-label="Switch branches or tags" tabindex="0" aria-haspopup="true">
    <span class="octicon octicon-git-branch"></span>
    <i>branch:</i>
    <span class="js-select-button css-truncate-target">master</span>
  </span>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax aria-hidden="true">

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <span class="select-menu-title">Switch branches/tags</span>
        <span class="octicon octicon-x js-menu-close"></span>
      </div> <!-- /.select-menu-header -->

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Filter branches/tags" id="context-commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" class="js-select-menu-tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" class="js-select-menu-tab">Tags</a>
            </li>
          </ul>
        </div><!-- /.select-menu-tabs -->
      </div><!-- /.select-menu-filters -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/DataTables/Plugins/blob/gh-pages/integration/jqueryui/dataTables.jqueryui.js"
                 data-name="gh-pages"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="gh-pages">gh-pages</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item selected">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/DataTables/Plugins/blob/master/integration/jqueryui/dataTables.jqueryui.js"
                 data-name="master"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="master">master</a>
            </div> <!-- /.select-menu-item -->
        </div>

          <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

    </div> <!-- /.select-menu-modal -->
  </div> <!-- /.select-menu-modal-holder -->
</div> <!-- /.select-menu -->

  <div class="button-group right">
    <a href="/DataTables/Plugins/find/master"
          class="js-show-file-finder minibutton empty-icon tooltipped tooltipped-s"
          data-pjax
          data-hotkey="t"
          aria-label="Quickly jump between files">
      <span class="octicon octicon-list-unordered"></span>
    </a>
    <button class="js-zeroclipboard minibutton zeroclipboard-button"
          data-clipboard-text="integration/jqueryui/dataTables.jqueryui.js"
          aria-label="Copy to clipboard"
          data-copied-hint="Copied!">
      <span class="octicon octicon-clippy"></span>
    </button>
  </div>

  <div class="breadcrumb">
    <span class='repo-root js-repo-root'><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/DataTables/Plugins" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">Plugins</span></a></span></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/DataTables/Plugins/tree/master/integration" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">integration</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/DataTables/Plugins/tree/master/integration/jqueryui" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">jqueryui</span></a></span><span class="separator"> / </span><strong class="final-path">dataTables.jqueryui.js</strong>
  </div>
</div>


  <div class="commit file-history-tease">
      <img alt="Allan Jardine" class="main-avatar js-avatar" data-user="278219" height="24" src="https://avatars1.githubusercontent.com/u/278219?s=140" width="24" />
      <span class="author"><a href="/DataTables" rel="author">DataTables</a></span>
      <time datetime="2014-04-28T09:05:07+01:00" is="relative-time">April 28, 2014</time>
      <div class="commit-title">
          <a href="/DataTables/Plugins/commit/e94211817885e6b651015a62b6b193b5439a2aaf" class="message" data-pjax="true" title="Update jQuery UI integration

- Fix error on span sorting class being applied to all span elements in
  the header cell
- Fix possible sort classes not working">Update jQuery UI integration</a>
      </div>

    <div class="participation">
      <p class="quickstat"><a href="#blob_contributors_box" rel="facebox"><strong>1</strong>  contributor</a></p>
      
    </div>
    <div id="blob_contributors_box" style="display:none">
      <h2 class="facebox-header">Users who have contributed to this file</h2>
      <ul class="facebox-user-list">
          <li class="facebox-user-list-item">
            <img alt="Allan Jardine" class=" js-avatar" data-user="278219" height="24" src="https://avatars1.githubusercontent.com/u/278219?s=140" width="24" />
            <a href="/DataTables">DataTables</a>
          </li>
      </ul>
    </div>
  </div>

<div class="file-box">
  <div class="file">
    <div class="meta clearfix">
      <div class="info file-name">
        <span class="icon"><b class="octicon octicon-file-text"></b></span>
        <span class="mode" title="File Mode">file</span>
        <span class="meta-divider"></span>
          <span>121 lines (99 sloc)</span>
          <span class="meta-divider"></span>
        <span>3.405 kb</span>
      </div>
      <div class="actions">
        <div class="button-group">
              <a class="minibutton disabled tooltipped tooltipped-w" href="#"
                 aria-label="You must be signed in to make or propose changes">Edit</a>
          <a href="/DataTables/Plugins/raw/master/integration/jqueryui/dataTables.jqueryui.js" class="minibutton " id="raw-url">Raw</a>
            <a href="/DataTables/Plugins/blame/master/integration/jqueryui/dataTables.jqueryui.js" class="minibutton js-update-url-with-hash">Blame</a>
          <a href="/DataTables/Plugins/commits/master/integration/jqueryui/dataTables.jqueryui.js" class="minibutton " rel="nofollow">History</a>
        </div><!-- /.button-group -->
          <a class="minibutton danger disabled empty-icon tooltipped tooltipped-w" href="#"
             aria-label="You must be signed in to make or propose changes">
          Delete
        </a>
      </div><!-- /.actions -->
    </div>
      
  <div class="blob-wrapper data type-javascript js-blob-data">
       <table class="file-code file-diff tab-size-8">
         <tr class="file-code-line">
           <td class="blob-line-nums">
             <span id="L1" rel="#L1">1</span>
<span id="L2" rel="#L2">2</span>
<span id="L3" rel="#L3">3</span>
<span id="L4" rel="#L4">4</span>
<span id="L5" rel="#L5">5</span>
<span id="L6" rel="#L6">6</span>
<span id="L7" rel="#L7">7</span>
<span id="L8" rel="#L8">8</span>
<span id="L9" rel="#L9">9</span>
<span id="L10" rel="#L10">10</span>
<span id="L11" rel="#L11">11</span>
<span id="L12" rel="#L12">12</span>
<span id="L13" rel="#L13">13</span>
<span id="L14" rel="#L14">14</span>
<span id="L15" rel="#L15">15</span>
<span id="L16" rel="#L16">16</span>
<span id="L17" rel="#L17">17</span>
<span id="L18" rel="#L18">18</span>
<span id="L19" rel="#L19">19</span>
<span id="L20" rel="#L20">20</span>
<span id="L21" rel="#L21">21</span>
<span id="L22" rel="#L22">22</span>
<span id="L23" rel="#L23">23</span>
<span id="L24" rel="#L24">24</span>
<span id="L25" rel="#L25">25</span>
<span id="L26" rel="#L26">26</span>
<span id="L27" rel="#L27">27</span>
<span id="L28" rel="#L28">28</span>
<span id="L29" rel="#L29">29</span>
<span id="L30" rel="#L30">30</span>
<span id="L31" rel="#L31">31</span>
<span id="L32" rel="#L32">32</span>
<span id="L33" rel="#L33">33</span>
<span id="L34" rel="#L34">34</span>
<span id="L35" rel="#L35">35</span>
<span id="L36" rel="#L36">36</span>
<span id="L37" rel="#L37">37</span>
<span id="L38" rel="#L38">38</span>
<span id="L39" rel="#L39">39</span>
<span id="L40" rel="#L40">40</span>
<span id="L41" rel="#L41">41</span>
<span id="L42" rel="#L42">42</span>
<span id="L43" rel="#L43">43</span>
<span id="L44" rel="#L44">44</span>
<span id="L45" rel="#L45">45</span>
<span id="L46" rel="#L46">46</span>
<span id="L47" rel="#L47">47</span>
<span id="L48" rel="#L48">48</span>
<span id="L49" rel="#L49">49</span>
<span id="L50" rel="#L50">50</span>
<span id="L51" rel="#L51">51</span>
<span id="L52" rel="#L52">52</span>
<span id="L53" rel="#L53">53</span>
<span id="L54" rel="#L54">54</span>
<span id="L55" rel="#L55">55</span>
<span id="L56" rel="#L56">56</span>
<span id="L57" rel="#L57">57</span>
<span id="L58" rel="#L58">58</span>
<span id="L59" rel="#L59">59</span>
<span id="L60" rel="#L60">60</span>
<span id="L61" rel="#L61">61</span>
<span id="L62" rel="#L62">62</span>
<span id="L63" rel="#L63">63</span>
<span id="L64" rel="#L64">64</span>
<span id="L65" rel="#L65">65</span>
<span id="L66" rel="#L66">66</span>
<span id="L67" rel="#L67">67</span>
<span id="L68" rel="#L68">68</span>
<span id="L69" rel="#L69">69</span>
<span id="L70" rel="#L70">70</span>
<span id="L71" rel="#L71">71</span>
<span id="L72" rel="#L72">72</span>
<span id="L73" rel="#L73">73</span>
<span id="L74" rel="#L74">74</span>
<span id="L75" rel="#L75">75</span>
<span id="L76" rel="#L76">76</span>
<span id="L77" rel="#L77">77</span>
<span id="L78" rel="#L78">78</span>
<span id="L79" rel="#L79">79</span>
<span id="L80" rel="#L80">80</span>
<span id="L81" rel="#L81">81</span>
<span id="L82" rel="#L82">82</span>
<span id="L83" rel="#L83">83</span>
<span id="L84" rel="#L84">84</span>
<span id="L85" rel="#L85">85</span>
<span id="L86" rel="#L86">86</span>
<span id="L87" rel="#L87">87</span>
<span id="L88" rel="#L88">88</span>
<span id="L89" rel="#L89">89</span>
<span id="L90" rel="#L90">90</span>
<span id="L91" rel="#L91">91</span>
<span id="L92" rel="#L92">92</span>
<span id="L93" rel="#L93">93</span>
<span id="L94" rel="#L94">94</span>
<span id="L95" rel="#L95">95</span>
<span id="L96" rel="#L96">96</span>
<span id="L97" rel="#L97">97</span>
<span id="L98" rel="#L98">98</span>
<span id="L99" rel="#L99">99</span>
<span id="L100" rel="#L100">100</span>
<span id="L101" rel="#L101">101</span>
<span id="L102" rel="#L102">102</span>
<span id="L103" rel="#L103">103</span>
<span id="L104" rel="#L104">104</span>
<span id="L105" rel="#L105">105</span>
<span id="L106" rel="#L106">106</span>
<span id="L107" rel="#L107">107</span>
<span id="L108" rel="#L108">108</span>
<span id="L109" rel="#L109">109</span>
<span id="L110" rel="#L110">110</span>
<span id="L111" rel="#L111">111</span>
<span id="L112" rel="#L112">112</span>
<span id="L113" rel="#L113">113</span>
<span id="L114" rel="#L114">114</span>
<span id="L115" rel="#L115">115</span>
<span id="L116" rel="#L116">116</span>
<span id="L117" rel="#L117">117</span>
<span id="L118" rel="#L118">118</span>
<span id="L119" rel="#L119">119</span>
<span id="L120" rel="#L120">120</span>

           </td>
           <td class="blob-line-code"><div class="code-body highlight"><pre><div class='line' id='LC1'><br/></div><div class='line' id='LC2'><span class="p">(</span><span class="kd">function</span><span class="p">(){</span></div><div class='line' id='LC3'><br/></div><div class='line' id='LC4'><span class="kd">var</span> <span class="nx">DataTable</span> <span class="o">=</span> <span class="nx">$</span><span class="p">.</span><span class="nx">fn</span><span class="p">.</span><span class="nx">dataTable</span><span class="p">;</span></div><div class='line' id='LC5'><span class="kd">var</span> <span class="nx">sort_prefix</span> <span class="o">=</span> <span class="s1">&#39;css_right ui-icon ui-icon-&#39;</span><span class="p">;</span></div><div class='line' id='LC6'><span class="kd">var</span> <span class="nx">toolbar_prefix</span> <span class="o">=</span> <span class="s1">&#39;fg-toolbar ui-toolbar ui-widget-header ui-helper-clearfix ui-corner-&#39;</span><span class="p">;</span></div><div class='line' id='LC7'><br/></div><div class='line' id='LC8'><span class="cm">/* Set the defaults for DataTables initialisation */</span></div><div class='line' id='LC9'><span class="nx">$</span><span class="p">.</span><span class="nx">extend</span><span class="p">(</span> <span class="kc">true</span><span class="p">,</span> <span class="nx">DataTable</span><span class="p">.</span><span class="nx">defaults</span><span class="p">,</span> <span class="p">{</span></div><div class='line' id='LC10'>	<span class="nx">dom</span><span class="o">:</span></div><div class='line' id='LC11'>		<span class="s1">&#39;&lt;&quot;&#39;</span><span class="o">+</span><span class="nx">toolbar_prefix</span><span class="o">+</span><span class="s1">&#39;tl ui-corner-tr&quot;lfr&gt;&#39;</span><span class="o">+</span></div><div class='line' id='LC12'>		<span class="s1">&#39;t&#39;</span><span class="o">+</span></div><div class='line' id='LC13'>		<span class="s1">&#39;&lt;&quot;&#39;</span><span class="o">+</span><span class="nx">toolbar_prefix</span><span class="o">+</span><span class="s1">&#39;bl ui-corner-br&quot;ip&gt;&#39;</span><span class="p">,</span></div><div class='line' id='LC14'>	<span class="nx">renderer</span><span class="o">:</span> <span class="s1">&#39;jqueryui&#39;</span></div><div class='line' id='LC15'><span class="p">}</span> <span class="p">);</span></div><div class='line' id='LC16'><br/></div><div class='line' id='LC17'><br/></div><div class='line' id='LC18'><span class="nx">$</span><span class="p">.</span><span class="nx">extend</span><span class="p">(</span> <span class="nx">DataTable</span><span class="p">.</span><span class="nx">ext</span><span class="p">.</span><span class="nx">classes</span><span class="p">,</span> <span class="p">{</span></div><div class='line' id='LC19'>	<span class="cm">/* Full numbers paging buttons */</span></div><div class='line' id='LC20'>	<span class="s2">&quot;sPageButton&quot;</span><span class="o">:</span>         <span class="s2">&quot;fg-button ui-button ui-state-default&quot;</span><span class="p">,</span></div><div class='line' id='LC21'>	<span class="s2">&quot;sPageButtonActive&quot;</span><span class="o">:</span>   <span class="s2">&quot;ui-state-disabled&quot;</span><span class="p">,</span></div><div class='line' id='LC22'>	<span class="s2">&quot;sPageButtonDisabled&quot;</span><span class="o">:</span> <span class="s2">&quot;ui-state-disabled&quot;</span><span class="p">,</span></div><div class='line' id='LC23'><br/></div><div class='line' id='LC24'>	<span class="cm">/* Features */</span></div><div class='line' id='LC25'>	<span class="s2">&quot;sPaging&quot;</span><span class="o">:</span> <span class="s2">&quot;dataTables_paginate fg-buttonset ui-buttonset fg-buttonset-multi &quot;</span><span class="o">+</span></div><div class='line' id='LC26'>		<span class="s2">&quot;ui-buttonset-multi paging_&quot;</span><span class="p">,</span> <span class="cm">/* Note that the type is postfixed */</span></div><div class='line' id='LC27'><br/></div><div class='line' id='LC28'>	<span class="cm">/* Sorting */</span></div><div class='line' id='LC29'>	<span class="s2">&quot;sSortAsc&quot;</span><span class="o">:</span>            <span class="s2">&quot;ui-state-default sorting_asc&quot;</span><span class="p">,</span></div><div class='line' id='LC30'>	<span class="s2">&quot;sSortDesc&quot;</span><span class="o">:</span>           <span class="s2">&quot;ui-state-default sorting_desc&quot;</span><span class="p">,</span></div><div class='line' id='LC31'>	<span class="s2">&quot;sSortable&quot;</span><span class="o">:</span>           <span class="s2">&quot;ui-state-default sorting&quot;</span><span class="p">,</span></div><div class='line' id='LC32'>	<span class="s2">&quot;sSortableAsc&quot;</span><span class="o">:</span>        <span class="s2">&quot;ui-state-default sorting_asc_disabled&quot;</span><span class="p">,</span></div><div class='line' id='LC33'>	<span class="s2">&quot;sSortableDesc&quot;</span><span class="o">:</span>       <span class="s2">&quot;ui-state-default sorting_desc_disabled&quot;</span><span class="p">,</span></div><div class='line' id='LC34'>	<span class="s2">&quot;sSortableNone&quot;</span><span class="o">:</span>       <span class="s2">&quot;ui-state-default sorting_disabled&quot;</span><span class="p">,</span></div><div class='line' id='LC35'>	<span class="s2">&quot;sSortIcon&quot;</span><span class="o">:</span>           <span class="s2">&quot;DataTables_sort_icon&quot;</span><span class="p">,</span></div><div class='line' id='LC36'><br/></div><div class='line' id='LC37'>	<span class="cm">/* Scrolling */</span></div><div class='line' id='LC38'>	<span class="s2">&quot;sScrollHead&quot;</span><span class="o">:</span> <span class="s2">&quot;dataTables_scrollHead &quot;</span><span class="o">+</span><span class="s2">&quot;ui-state-default&quot;</span><span class="p">,</span></div><div class='line' id='LC39'>	<span class="s2">&quot;sScrollFoot&quot;</span><span class="o">:</span> <span class="s2">&quot;dataTables_scrollFoot &quot;</span><span class="o">+</span><span class="s2">&quot;ui-state-default&quot;</span><span class="p">,</span></div><div class='line' id='LC40'><br/></div><div class='line' id='LC41'>	<span class="cm">/* Misc */</span></div><div class='line' id='LC42'>	<span class="s2">&quot;sHeaderTH&quot;</span><span class="o">:</span>  <span class="s2">&quot;ui-state-default&quot;</span><span class="p">,</span></div><div class='line' id='LC43'>	<span class="s2">&quot;sFooterTH&quot;</span><span class="o">:</span>  <span class="s2">&quot;ui-state-default&quot;</span><span class="p">,</span></div><div class='line' id='LC44'><span class="p">}</span> <span class="p">);</span></div><div class='line' id='LC45'><br/></div><div class='line' id='LC46'><br/></div><div class='line' id='LC47'><span class="nx">$</span><span class="p">.</span><span class="nx">fn</span><span class="p">.</span><span class="nx">DataTable</span><span class="p">.</span><span class="nx">ext</span><span class="p">.</span><span class="nx">renderer</span><span class="p">.</span><span class="nx">header</span><span class="p">.</span><span class="nx">jqueryui</span> <span class="o">=</span> <span class="kd">function</span> <span class="p">(</span> <span class="nx">settings</span><span class="p">,</span> <span class="nx">cell</span><span class="p">,</span> <span class="nx">column</span><span class="p">,</span> <span class="nx">classes</span> <span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC48'>	<span class="c1">// Calculate what the unsorted class should be</span></div><div class='line' id='LC49'>	<span class="kd">var</span> <span class="nx">noSortAppliedClass</span> <span class="o">=</span> <span class="nx">sort_prefix</span><span class="o">+</span><span class="s1">&#39;carat-2-n-s&#39;</span><span class="p">;</span></div><div class='line' id='LC50'>	<span class="kd">var</span> <span class="nx">asc</span> <span class="o">=</span> <span class="nx">$</span><span class="p">.</span><span class="nx">inArray</span><span class="p">(</span><span class="s1">&#39;asc&#39;</span><span class="p">,</span> <span class="nx">column</span><span class="p">.</span><span class="nx">asSorting</span><span class="p">)</span> <span class="o">!==</span> <span class="o">-</span><span class="mi">1</span><span class="p">;</span></div><div class='line' id='LC51'>	<span class="kd">var</span> <span class="nx">desc</span> <span class="o">=</span> <span class="nx">$</span><span class="p">.</span><span class="nx">inArray</span><span class="p">(</span><span class="s1">&#39;desc&#39;</span><span class="p">,</span> <span class="nx">column</span><span class="p">.</span><span class="nx">asSorting</span><span class="p">)</span> <span class="o">!==</span> <span class="o">-</span><span class="mi">1</span><span class="p">;</span></div><div class='line' id='LC52'><br/></div><div class='line' id='LC53'>	<span class="k">if</span> <span class="p">(</span> <span class="o">!</span><span class="nx">column</span><span class="p">.</span><span class="nx">bSortable</span> <span class="o">||</span> <span class="p">(</span><span class="o">!</span><span class="nx">asc</span> <span class="o">&amp;&amp;</span> <span class="o">!</span><span class="nx">desc</span><span class="p">)</span> <span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC54'>		<span class="nx">noSortAppliedClass</span> <span class="o">=</span> <span class="s1">&#39;&#39;</span><span class="p">;</span></div><div class='line' id='LC55'>	<span class="p">}</span></div><div class='line' id='LC56'>	<span class="k">else</span> <span class="k">if</span> <span class="p">(</span> <span class="nx">asc</span> <span class="o">&amp;&amp;</span> <span class="o">!</span><span class="nx">desc</span> <span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC57'>		<span class="nx">noSortAppliedClass</span> <span class="o">=</span> <span class="nx">sort_prefix</span><span class="o">+</span><span class="s1">&#39;carat-1-n&#39;</span><span class="p">;</span></div><div class='line' id='LC58'>	<span class="p">}</span></div><div class='line' id='LC59'>	<span class="k">else</span> <span class="k">if</span> <span class="p">(</span> <span class="o">!</span><span class="nx">asc</span> <span class="o">&amp;&amp;</span> <span class="nx">desc</span> <span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC60'>		<span class="nx">noSortAppliedClass</span> <span class="o">=</span> <span class="nx">sort_prefix</span><span class="o">+</span><span class="s1">&#39;carat-1-s&#39;</span><span class="p">;</span></div><div class='line' id='LC61'>	<span class="p">}</span></div><div class='line' id='LC62'><br/></div><div class='line' id='LC63'>	<span class="c1">// Setup the DOM structure</span></div><div class='line' id='LC64'>	<span class="nx">$</span><span class="p">(</span><span class="s1">&#39;&lt;div/&gt;&#39;</span><span class="p">)</span></div><div class='line' id='LC65'>		<span class="p">.</span><span class="nx">addClass</span><span class="p">(</span> <span class="s1">&#39;DataTables_sort_wrapper&#39;</span> <span class="p">)</span></div><div class='line' id='LC66'>		<span class="p">.</span><span class="nx">append</span><span class="p">(</span> <span class="nx">cell</span><span class="p">.</span><span class="nx">contents</span><span class="p">()</span> <span class="p">)</span></div><div class='line' id='LC67'>		<span class="p">.</span><span class="nx">append</span><span class="p">(</span> <span class="nx">$</span><span class="p">(</span><span class="s1">&#39;&lt;span/&gt;&#39;</span><span class="p">)</span></div><div class='line' id='LC68'>			<span class="p">.</span><span class="nx">addClass</span><span class="p">(</span> <span class="nx">classes</span><span class="p">.</span><span class="nx">sSortIcon</span><span class="o">+</span><span class="s1">&#39; &#39;</span><span class="o">+</span><span class="nx">noSortAppliedClass</span> <span class="p">)</span></div><div class='line' id='LC69'>		<span class="p">)</span></div><div class='line' id='LC70'>		<span class="p">.</span><span class="nx">appendTo</span><span class="p">(</span> <span class="nx">cell</span> <span class="p">);</span></div><div class='line' id='LC71'><br/></div><div class='line' id='LC72'>	<span class="c1">// Attach a sort listener to update on sort</span></div><div class='line' id='LC73'>	<span class="nx">$</span><span class="p">(</span><span class="nx">settings</span><span class="p">.</span><span class="nx">nTable</span><span class="p">).</span><span class="nx">on</span><span class="p">(</span> <span class="s1">&#39;order.dt&#39;</span><span class="p">,</span> <span class="kd">function</span> <span class="p">(</span> <span class="nx">e</span><span class="p">,</span> <span class="nx">settings</span><span class="p">,</span> <span class="nx">sorting</span><span class="p">,</span> <span class="nx">columns</span> <span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC74'>		<span class="kd">var</span> <span class="nx">colIdx</span> <span class="o">=</span> <span class="nx">column</span><span class="p">.</span><span class="nx">idx</span><span class="p">;</span></div><div class='line' id='LC75'><br/></div><div class='line' id='LC76'>		<span class="nx">cell</span></div><div class='line' id='LC77'>			<span class="p">.</span><span class="nx">removeClass</span><span class="p">(</span> <span class="nx">classes</span><span class="p">.</span><span class="nx">sSortAsc</span> <span class="o">+</span><span class="s2">&quot; &quot;</span><span class="o">+</span><span class="nx">classes</span><span class="p">.</span><span class="nx">sSortDesc</span> <span class="p">)</span></div><div class='line' id='LC78'>			<span class="p">.</span><span class="nx">addClass</span><span class="p">(</span> <span class="nx">columns</span><span class="p">[</span> <span class="nx">colIdx</span> <span class="p">]</span> <span class="o">==</span> <span class="s1">&#39;asc&#39;</span> <span class="o">?</span></div><div class='line' id='LC79'>				<span class="nx">classes</span><span class="p">.</span><span class="nx">sSortAsc</span> <span class="o">:</span> <span class="nx">columns</span><span class="p">[</span> <span class="nx">colIdx</span> <span class="p">]</span> <span class="o">==</span> <span class="s1">&#39;desc&#39;</span> <span class="o">?</span></div><div class='line' id='LC80'>					<span class="nx">classes</span><span class="p">.</span><span class="nx">sSortDesc</span> <span class="o">:</span></div><div class='line' id='LC81'>					<span class="nx">column</span><span class="p">.</span><span class="nx">sSortingClass</span></div><div class='line' id='LC82'>			<span class="p">);</span></div><div class='line' id='LC83'><br/></div><div class='line' id='LC84'>		<span class="nx">cell</span></div><div class='line' id='LC85'>			<span class="p">.</span><span class="nx">find</span><span class="p">(</span> <span class="s1">&#39;span.&#39;</span><span class="o">+</span><span class="nx">classes</span><span class="p">.</span><span class="nx">sSortIcon</span> <span class="p">)</span></div><div class='line' id='LC86'>			<span class="p">.</span><span class="nx">removeClass</span><span class="p">(</span></div><div class='line' id='LC87'>				<span class="nx">sort_prefix</span><span class="o">+</span><span class="s1">&#39;triangle-1-n&#39;</span> <span class="o">+</span><span class="s2">&quot; &quot;</span><span class="o">+</span></div><div class='line' id='LC88'>				<span class="nx">sort_prefix</span><span class="o">+</span><span class="s1">&#39;triangle-1-s&#39;</span> <span class="o">+</span><span class="s2">&quot; &quot;</span><span class="o">+</span></div><div class='line' id='LC89'>				<span class="nx">sort_prefix</span><span class="o">+</span><span class="s1">&#39;carat-2-n-s&#39;</span> <span class="o">+</span><span class="s2">&quot; &quot;</span><span class="o">+</span></div><div class='line' id='LC90'>				<span class="nx">sort_prefix</span><span class="o">+</span><span class="s1">&#39;carat-1-n&#39;</span> <span class="o">+</span><span class="s2">&quot; &quot;</span><span class="o">+</span></div><div class='line' id='LC91'>				<span class="nx">sort_prefix</span><span class="o">+</span><span class="s1">&#39;carat-1-s&#39;</span></div><div class='line' id='LC92'>			<span class="p">)</span></div><div class='line' id='LC93'>			<span class="p">.</span><span class="nx">addClass</span><span class="p">(</span> <span class="nx">columns</span><span class="p">[</span> <span class="nx">colIdx</span> <span class="p">]</span> <span class="o">==</span> <span class="s1">&#39;asc&#39;</span> <span class="o">?</span></div><div class='line' id='LC94'>				<span class="nx">sort_prefix</span><span class="o">+</span><span class="s1">&#39;triangle-1-n&#39;</span> <span class="o">:</span> <span class="nx">columns</span><span class="p">[</span> <span class="nx">colIdx</span> <span class="p">]</span> <span class="o">==</span> <span class="s1">&#39;desc&#39;</span> <span class="o">?</span></div><div class='line' id='LC95'>					<span class="nx">sort_prefix</span><span class="o">+</span><span class="s1">&#39;triangle-1-s&#39;</span> <span class="o">:</span></div><div class='line' id='LC96'>					<span class="nx">noSortAppliedClass</span></div><div class='line' id='LC97'>			<span class="p">);</span></div><div class='line' id='LC98'>	<span class="p">}</span> <span class="p">);</span></div><div class='line' id='LC99'><span class="p">};</span></div><div class='line' id='LC100'><br/></div><div class='line' id='LC101'><br/></div><div class='line' id='LC102'><span class="cm">/*</span></div><div class='line' id='LC103'><span class="cm"> * TableTools jQuery UI compatibility</span></div><div class='line' id='LC104'><span class="cm"> * Required TableTools 2.1+</span></div><div class='line' id='LC105'><span class="cm"> */</span></div><div class='line' id='LC106'><span class="k">if</span> <span class="p">(</span> <span class="nx">DataTable</span><span class="p">.</span><span class="nx">TableTools</span> <span class="p">)</span> <span class="p">{</span></div><div class='line' id='LC107'>	<span class="nx">$</span><span class="p">.</span><span class="nx">extend</span><span class="p">(</span> <span class="kc">true</span><span class="p">,</span> <span class="nx">DataTable</span><span class="p">.</span><span class="nx">TableTools</span><span class="p">.</span><span class="nx">classes</span><span class="p">,</span> <span class="p">{</span></div><div class='line' id='LC108'>		<span class="s2">&quot;container&quot;</span><span class="o">:</span> <span class="s2">&quot;DTTT_container ui-buttonset ui-buttonset-multi&quot;</span><span class="p">,</span></div><div class='line' id='LC109'>		<span class="s2">&quot;buttons&quot;</span><span class="o">:</span> <span class="p">{</span></div><div class='line' id='LC110'>			<span class="s2">&quot;normal&quot;</span><span class="o">:</span> <span class="s2">&quot;DTTT_button ui-button ui-state-default&quot;</span></div><div class='line' id='LC111'>		<span class="p">},</span></div><div class='line' id='LC112'>		<span class="s2">&quot;collection&quot;</span><span class="o">:</span> <span class="p">{</span></div><div class='line' id='LC113'>			<span class="s2">&quot;container&quot;</span><span class="o">:</span> <span class="s2">&quot;DTTT_collection ui-buttonset ui-buttonset-multi&quot;</span></div><div class='line' id='LC114'>		<span class="p">}</span></div><div class='line' id='LC115'>	<span class="p">}</span> <span class="p">);</span></div><div class='line' id='LC116'><span class="p">}</span></div><div class='line' id='LC117'><br/></div><div class='line' id='LC118'><br/></div><div class='line' id='LC119'><span class="p">}());</span></div><div class='line' id='LC120'><br/></div></pre></div></td>
         </tr>
       </table>
  </div>

  </div>
</div>

<a href="#jump-to-line" rel="facebox[.linejump]" data-hotkey="l" class="js-jump-to-line" style="display:none">Jump to Line</a>
<div id="jump-to-line" style="display:none">
  <form accept-charset="UTF-8" class="js-jump-to-line-form">
    <input class="linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" autofocus>
    <button type="submit" class="button">Go</button>
  </form>
</div>

        </div>

      </div><!-- /.repo-container -->
      <div class="modal-backdrop"></div>
    </div><!-- /.container -->
  </div><!-- /.site -->


    </div><!-- /.wrapper -->

      <div class="container">
  <div class="site-footer">
    <ul class="site-footer-links right">
      <li><a href="https://status.github.com/">Status</a></li>
      <li><a href="http://developer.github.com">API</a></li>
      <li><a href="http://training.github.com">Training</a></li>
      <li><a href="http://shop.github.com">Shop</a></li>
      <li><a href="/blog">Blog</a></li>
      <li><a href="/about">About</a></li>

    </ul>

    <a href="/">
      <span class="mega-octicon octicon-mark-github" title="GitHub"></span>
    </a>

    <ul class="site-footer-links">
      <li>&copy; 2014 <span title="0.05750s from github-fe127-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="/site/terms">Terms</a></li>
        <li><a href="/site/privacy">Privacy</a></li>
        <li><a href="/security">Security</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
  </div><!-- /.site-footer -->
</div><!-- /.container -->


    <div class="fullscreen-overlay js-fullscreen-overlay" id="fullscreen_overlay">
  <div class="fullscreen-container js-fullscreen-container">
    <div class="textarea-wrap">
      <textarea name="fullscreen-contents" id="fullscreen-contents" class="fullscreen-contents js-fullscreen-contents" placeholder="" data-suggester="fullscreen_suggester"></textarea>
    </div>
  </div>
  <div class="fullscreen-sidebar">
    <a href="#" class="exit-fullscreen js-exit-fullscreen tooltipped tooltipped-w" aria-label="Exit Zen Mode">
      <span class="mega-octicon octicon-screen-normal"></span>
    </a>
    <a href="#" class="theme-switcher js-theme-switcher tooltipped tooltipped-w"
      aria-label="Switch themes">
      <span class="octicon octicon-color-mode"></span>
    </a>
  </div>
</div>



    <div id="ajax-error-message" class="flash flash-error">
      <span class="octicon octicon-alert"></span>
      <a href="#" class="octicon octicon-x close js-ajax-error-dismiss" aria-label="Dismiss error"></a>
      Something went wrong with that request. Please try again.
    </div>


      <script crossorigin="anonymous" src="https://assets-cdn.github.com/assets/frameworks-51e3b077e56f2f3244290e430b8d05253607065b.js" type="text/javascript"></script>
      <script async="async" crossorigin="anonymous" src="https://assets-cdn.github.com/assets/github-8dbe1dbe689fbe0a47e0c61c25c0929ff88ad651.js" type="text/javascript"></script>
      
      
        <script async src="https://www.google-analytics.com/analytics.js"></script>
  </body>
</html>

