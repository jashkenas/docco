    module.exports = '<!DOCTYPE html>
    <html>
    <head>
      <title><%= title %></title>
      <meta http-equiv="content-type" content="text/html; charset=UTF-8">
      <meta name="viewport" content="width=device-width, target-densitydpi=160dpi, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
      <link rel="stylesheet" media="all" href="<%= css %>" />
    </head>
    <body>
      <div id="container">
        <div id="background"></div>
        <% if (sources.length > 1) { %>
          <ul id="jump_to">
            <li>
              <a class="large" href="javascript:void(0);">Jump To &hellip;</a>
              <a class="small" href="javascript:void(0);">+</a>
              <div id="jump_wrapper">
              <div id="jump_page">
                <% for (var i=0, l=sources.length; i<l; i++) { %>
                  <% var source = sources[i]; %>
                  <a class="source" href="<%= destination(source) %>">
                    <%= path.basename(source) %>
                  </a>
                <% } %>
              </div>
            </li>
          </ul>
        <% } %>
        <ul class="sections">
            <% if (!hasTitle) { %>
              <li id="title">
                  <div class="annotation">
                      <h1><%= title %></h1>
                  </div>
              </li>
            <% } %>
            <% for (var i=0, l=sections.length; i<l; i++) { %>
            <% var section = sections[i]; %>
            <li id="section-<%= i + 1 %>">
                <div class="annotation">
                  <% heading = section.docsHtml.match(/^\s*<(h\d)>/) %>
                  <div class="pilwrap <%= heading ? \'for-\' + heading[1] : \'\' %>">
                    <a class="pilcrow" href="#section-<%= i + 1 %>">&#182;</a>
                  </div>
                  <%= section.docsHtml %>
                </div>
                <% if (section.codeText.replace(/\s/gm, \'\') != \'\') { %>
                <div class="content"><%= section.codeHtml %></div>
                <% } %>
            </li>
            <% } %>
        </ul>
      </div>
    </body>
    </html>'