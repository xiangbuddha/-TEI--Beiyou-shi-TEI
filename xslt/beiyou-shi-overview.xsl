<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xml="http://www.w3.org/XML/1998/namespace"
  exclude-result-prefixes="tei xml">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:key name="kRdgText"
           match="tei:rdg[not(contains(@ana, '#agree')) and (normalize-space(string(.))!='' or * or @ana)]"
           use="concat(generate-id(..), '|', normalize-space(string(.)))"/>

  <xsl:key name="kVarDedup"
           match="tei:rdg[not(contains(@ana, '#agree')) and (normalize-space(string(.))!='' or *)]"
           use="concat(generate-id(ancestor::tei:l),
                       '|',
                       normalize-space(translate(@wit,'#','')),
                       '|',
                       normalize-space(string(.)))"/>

  <xsl:key name="kWitInLine"
           match="tei:rdg[not(contains(@ana, '#agree')) and (normalize-space(string(.))!='' or * or @ana)]"
           use="concat(generate-id(ancestor::tei:l), '|', normalize-space(translate(@wit,'#','')))"/>

  <xsl:template name="wit-normalize">
    <xsl:param name="wit"/>
    <xsl:value-of select="normalize-space(translate($wit,'#',''))"/>
  </xsl:template>

  <xsl:template name="wit-label-list">
    <xsl:param name="wits"/>
    <xsl:variable name="raw">
      <xsl:if test="contains($wits, 'GX')">古香樓抄本、</xsl:if>
      <xsl:if test="contains($wits, 'MY')">眠雲精舍抄本、</xsl:if>
      <xsl:if test="contains($wits, 'ZQ')">振綺堂抄本、</xsl:if>
      <xsl:if test="contains($wits, 'Bao')">吳、鮑《楚石北遊詩》、</xsl:if>
      <xsl:if test="contains($wits, 'Yu')">《楚石梵琦全集》、</xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($raw) &gt; 0">
        <xsl:value-of select="substring($raw, 1, string-length($raw) - 1)"/>
      </xsl:when>
      <xsl:otherwise>底本</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="wit-label">
    <xsl:param name="id"/>
    <xsl:call-template name="wit-label-list">
      <xsl:with-param name="wits" select="$id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="poem-id">
    <xsl:choose>
      <xsl:when test="@xml:id"><xsl:value-of select="@xml:id"/></xsl:when>
      <xsl:otherwise>poem-<xsl:value-of select="generate-id()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="repeat-square">
    <xsl:param name="n"/>
    <xsl:if test="number($n) &gt; 0">
      <xsl:text>□</xsl:text>
      <xsl:call-template name="repeat-square">
        <xsl:with-param name="n" select="number($n) - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="text-extract">
    <xsl:apply-templates mode="text-extract"/>
  </xsl:template>

  <xsl:template match="text()" mode="text-extract">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="tei:gap" mode="text-extract">
    <xsl:choose>
      <xsl:when test="@quantity">
        <xsl:call-template name="repeat-square">
          <xsl:with-param name="n" select="@quantity"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>□</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:note" mode="text-extract"/>

  <xsl:template match="tei:choice" mode="text-extract">
    <xsl:choose>
      <xsl:when test="tei:reg"><xsl:apply-templates select="tei:reg" mode="text-extract"/></xsl:when>
      <xsl:when test="tei:corr"><xsl:apply-templates select="tei:corr" mode="text-extract"/></xsl:when>
      <xsl:otherwise><xsl:apply-templates mode="text-extract"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/tei:TEI">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <title>
          <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/>
        </title>

        <style type="text/css"><![CDATA[
          :root {
            --w: 520px;
            --main-font-size: 23pt;
            --note-font-size: 18pt;
          }

          /* 強制通篇使用細明體 */
          body, body * {
            font-family: "MingLiU", "細明體", "PMingLiU", "新細明體", serif !important;
          }

          body {
            margin: 0;
            line-height: 1.75;
            font-size: var(--main-font-size);
          }

          .wrap { display:flex; min-height:100vh; }
          nav {
            width:var(--w);
            border-right:1px solid #ddd;
            padding:16px 14px;
            position:sticky;
            top:0;
            height:100vh;
            overflow:auto;
            background:#fafafa;
            word-break: keep-all;
            overflow-wrap: anywhere;
          }
          main { flex:1; padding:16px 28px 60px 28px; }

          h1 { font-size:18pt; margin:0 0 10px 0; font-weight:700; }
          .meta { color:#666; font-size:18pt; margin:8px 0 12px 0; }
          .ctrl { margin:10px 0 14px 0; }
          .ctrl label { font-size:18pt; color:#444; display:block; margin-bottom:6px; }
          .ctrl select { width:100%; padding:6px 8px; font-size:18pt; }
          .ctrl .checkrow { margin-top:10px; }
          .ctrl .checkrow label { display:flex; gap:8px; align-items:center; margin:0; }

          .searchbox { margin-top:12px; padding-top:10px; border-top:1px solid #e6e6e6; }
          .searchbox input[type="text"]{
            width:100%; box-sizing:border-box; padding:7px 8px; font-size:15pt;
            border:1px solid #ccc; border-radius:6px;
          }
          .searchrow{ display:flex; gap:6px; margin-top:8px; flex-wrap:wrap; }
          .searchrow button{
            font-size:15pt; padding:5px 8px; border:1px solid #ccc;
            background:#fff; border-radius:6px; cursor:pointer;
          }
          .searchrow button:hover{ background:#f3f3f3; }
          .searchopt{ margin-top:8px; font-size:18pt; color:#444; display:flex; flex-direction:column; gap:6px; }
          .searchmeta{ margin-top:8px; font-size:18pt; color:#666; }

          mark.hit{ background:#fff3cd; padding:0 1px; border-radius:2px; }
          mark.hit.cur{ outline:2px solid #ff9900; }

          /* 異文高亮：淺黃底，深紫字 */
          .diff{ background-color:#fff3cd; color:#5e35b1; font-weight:bold; border-radius:2px; padding:0 1px; }

          body[data-view="all"] .app[data-hasdiff="1"] .chosen{
            background:#d8ecff; border-radius:2px;
            padding:0 1px;
          }
          .diffsrc{
            display:none; margin-left:2px;
            vertical-align: super;
            font-size: 0.7em;
            color:#0056b3;
            white-space: nowrap;
          }
          body[data-view="all"] .app[data-hasdiff="1"] .diffsrc{ display:inline; }

          .poem {
            margin:10px 0 18px 0; padding:10px 12px;
            border:1px solid #e6e6e6;
            border-radius:8px;
            background:#fff;
          }
          /* 強制隱藏的詩作與目錄項目 */
          .poem.hidden { display: none !important; }

          ul.toc { margin:0; padding-left:0; list-style:none; }
          ul.toc li { margin:4px 0; display:flex; gap:8px; align-items:flex-start; }
          ul.toc li.hidden { display: none !important; }
          .tocnum { color:#666; min-width:2.5em; text-align:right; font-variant-numeric: tabular-nums; }
          ul.toc li.active{ background:#fff3cd; border-radius:8px; padding:4px 6px; }
          a { text-decoration:none; color:#000; }
          a:hover { text-decoration:underline; }
          ul.toc a { white-space: normal; }

          .poem-title {
            font-size: var(--main-font-size); margin: 0 0 8px 0;
            font-weight: 700;
          }

          .l {
            white-space: pre-wrap; margin: 2px 0;
            font-size: var(--main-font-size);
          }
          .lg { margin-top:8px; padding-left:6px; }

          /* 切換視圖時控制注記顯示 */
          .lem-wit-note { display:none; }
          body[data-view="all"] .lem-wit-note {
            display: inline !important;
            color: #d63384;
            font-size: 0.85em;
          }
          body[data-view="all"] .headvars { display: inline !important; }

          .varline {
            display:none; margin:6px 0 10px 0; padding-left:6px;
            color:#666; font-size: var(--main-font-size);
          }
          .varline .tag {
            display:block; width:fit-content; padding:2px 8px; border:1px solid #ddd;
            border-radius:10px; margin-bottom:6px; background:#f7f7f7;
            color:#555; font-size:18pt;
          }
          .varline .item { margin-bottom:4px; }
          body[data-view="all"] .varline { display:block; }

          .critnote.seal {
             display: block !important; margin-top: 20px;
             margin-bottom: 20px;
             padding: 10px;
             border: 2px solid #d63384;
             color: #a00;
             background-color: #fff5f5;
             font-size: 20pt;
             width: fit-content;
          }
          .critnote.seal::before { content: "【印章】"; font-weight: bold; margin-right: 5px; }

          .trailer {
             text-align: right; margin-top: 15px;
             font-size: var(--main-font-size);
             color: #444;
          }

          .rend-small { font-size: 0.85em; }
          .rend-big   { font-size: 1.15em; font-weight: bold; }
          .rend-sup   { vertical-align: super; font-size: 0.75em; }
          .rend-sub   { vertical-align: sub; font-size: 0.75em; }
          .rend-bold  { font-weight: bold; }
          .rend-italic{ font-style: italic; }

          .critnote{
            display:none; margin:2px 0 0 6px;
            font-size:20pt;
            color:#d63384;
          }
          body[data-notes="on"] .critnote{ display:block; }
          .critnote.headnote{ border-left:4px solid #d63384; padding-left:10px; }
          .critnote p { margin: 0; }
          .critnote p + p { margin-top: 4px; }

          .app .variants { display:none; }

          .choice .sic { display:none; }
          body[data-editor="on"] .choice .sic{
            display:inline; color:#c00000; text-decoration: line-through;
            margin-right:4px;
          }
          body[data-editor="on"] .choice .corr{
            background:#fff3cd; padding:0 2px;
          }

          .del{ color:#c00000; text-decoration: line-through; }
          .add{ color:#c00000; }
          .gap{ color:#333; letter-spacing:2px; }

          .critnote.force-show, .varline.force-show { display:block !important; }

          .back {
            margin: 14px 0 0 0; padding: 10px 12px;
            border: 1px dashed #ddd;
            border-radius: 8px;
            background: #fff;
          }

          .unclear { border-bottom: 1px dashed #999; color: #666; cursor: help; }
          .damage { color: #c00000; font-size: 0.85em; }
          .gaiji { border-bottom: 1px dotted #17a2b8; cursor: help; }
          .punct { color: #555; }
        ]]></style>

        <script type="text/javascript"><![CDATA[
          function htmlOf(node){ return node ? (node.innerHTML || "").trim() : ""; }

          function hasWit(span, wit){
            if(!span) return false;
            var w = (span.getAttribute("data-wits") || "").split(/\s+/);
            for(var i=0;i<w.length;i++){ if(w[i]===wit) return true; }
            return false;
          }

          function chooseForApp(app, view){
            var chosen = app.querySelector(".chosen");
            if(!chosen) return;

            if(view==="main" || view==="all"){
              var lem = app.querySelector(".variants .lem");
              chosen.innerHTML = htmlOf(lem);
              return;
            }

            var target = view;
            var rdgs = app.querySelectorAll(".variants .rdg");
            for(var i=0;i<rdgs.length;i++){
              if(hasWit(rdgs[i], target)){
                chosen.innerHTML = htmlOf(rdgs[i]);
                return;
              }
            }
            var lem2 = app.querySelector(".variants .lem");
            if(lem2 && hasWit(lem2, target)){
              chosen.innerHTML = htmlOf(lem2);
              return;
            }
            chosen.innerHTML = htmlOf(lem2);
          }

          function escapeHtml(s){
            return (s || "").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#39;");
          }

          function commonPrefixLen(a,b){
            var n = Math.min(a.length,b.length);
            var i=0; for(; i<n; i++){ if(a.charAt(i)!==b.charAt(i)) break; }
            return i;
          }
          function commonSuffixLen(a,b,cut){
            var i=a.length-1, j=b.length-1, k=0;
            while(i>=cut && j>=cut){
              if(a.charAt(i)!==b.charAt(j)) break;
              k++; i--; j--;
            }
            return k;
          }

          function applyAllDiff(){
            var on = (document.body.getAttribute("data-view")==="all");
            var items = document.querySelectorAll(".varline .item[data-lem][data-rdg]");
            for(var i=0;i<items.length;i++){
              var it = items[i];
              var span = it.querySelector(".rdgtext");
              if(!span) continue;
              var lem = it.getAttribute("data-lem") || "";
              var rdg = it.getAttribute("data-rdg") || "";
              if(!it.hasAttribute("data-raw")) it.setAttribute("data-raw", rdg);
              else rdg = it.getAttribute("data-raw") || rdg;

              if(!on){ span.textContent = rdg; continue; }
              if(!lem || !rdg || lem === rdg){ span.textContent = rdg; continue; }

              var pre = commonPrefixLen(lem, rdg);
              var suf = commonSuffixLen(lem, rdg, pre);
              var midLen = rdg.length - pre - suf;
              if(midLen <= 0){ span.textContent = rdg; continue; }
              var head = rdg.substring(0, pre);
              var mid  = rdg.substring(pre, pre + midLen);
              var tail = rdg.substring(rdg.length - suf);
              span.innerHTML = escapeHtml(head) + '<span class="diff">' + escapeHtml(mid) + '</span>' + escapeHtml(tail);
            }
          }

          function filterPoemsByView(view){
            var restrict = (view === "MY" || view === "ZQ");

            var poems = document.querySelectorAll(".poem");
            for(var i=0;i<poems.length;i++){
              var id = poems[i].getAttribute("id") || "";
              var hide = false;

              if(restrict){
                var m = id.match(/^by(\d+)$/);
                if(m){
                  var n = parseInt(m[1], 10);
                  if(n >= 318 && n <= 322){
                    hide = true;
                  }
                }
              }

              poems[i].classList.toggle("hidden", hide);

              if(hide && poems[i].classList.contains("selected")){
                clearSelectedPoem();
              }
            }

            var tocItems = document.querySelectorAll("ul.toc li");
            for(var j=0;j<tocItems.length;j++){
              var link = tocItems[j].querySelector("a");
              var hideToc = false;

              if(restrict && link){
                var href = link.getAttribute("href") || "";
                var pid = href.replace(/^#/, "");
                var m2 = pid.match(/^by(\d+)$/);
                if(m2){
                  var n2 = parseInt(m2[1], 10);
                  if(n2 >= 318 && n2 <= 322){
                    hideToc = true;
                  }
                }
              }

              tocItems[j].classList.toggle("hidden", hideToc);

              if(hideToc && tocItems[j].classList.contains("active")){
                tocItems[j].classList.remove("active");
              }
            }
          }

          function applyView(view){
            document.body.setAttribute("data-view", view);
            filterPoemsByView(view);

            var apps = document.querySelectorAll(".app");
            for(var i=0;i<apps.length;i++){ chooseForApp(apps[i], view); }
            applyAllDiff();
          }

          function applyNotes(on){ document.body.setAttribute("data-notes", on ? "on" : "off"); }
          function applyEditor(on){ document.body.setAttribute("data-editor", on ? "on" : "off"); }

          function clearSelectedPoem(){
            var prev = document.querySelector(".poem.selected");
            if(prev) prev.classList.remove("selected");
            var active = document.querySelector("ul.toc li.active");
            if(active) active.classList.remove("active");
          }

          function setSelectedPoemById(id){
            if(!id) return;
            var poem = document.getElementById(id);
            if(!poem) return;
            clearSelectedPoem();
            poem.classList.add("selected");
            poem.classList.remove("hidden");
            var link = document.querySelector("ul.toc a[href='#"+ CSS.escape(id) +"']");
            if(link){
              var li = link.closest("li");
              if(li){ li.classList.add("active"); li.classList.remove("hidden"); }
            }
          }

          function initPoemSelect(){
            var tocLinks = document.querySelectorAll("ul.toc a[href^='#']");
            for(var i=0;i<tocLinks.length;i++){
              tocLinks[i].addEventListener("click", function(){
                var href = this.getAttribute("href") || "";
                var id = href.charAt(0)==="#" ? href.substring(1) : href;
                setTimeout(function(){ setSelectedPoemById(id); }, 0);
              });
            }
            var poems = document.querySelectorAll(".poem");
            for(var j=0;j<poems.length;j++){
              poems[j].addEventListener("click", function(){
                var id = this.getAttribute("id") || "";
                if(!id) return;
                setSelectedPoemById(id);
                if(location.hash !== "#"+id){
                  if(history && history.replaceState) history.replaceState(null, "", "#"+id);
                  else location.hash = "#"+id;
                }
              });
            }
            if(location.hash && location.hash.length>1){
              setSelectedPoemById(location.hash.substring(1));
            }
            window.addEventListener("hashchange", function(){
              if(location.hash && location.hash.length>1){
                setSelectedPoemById(location.hash.substring(1));
              }
            });
          }

          var __hits = [];
          var __hitIndex = -1;
          function escapeRegExp(s){ return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); }
          function setMeta(msg){ var el = document.getElementById("searchMeta"); if(el) el.textContent = msg || ""; }
          function clearCurrent(){ for(var i=0;i<__hits.length;i++) __hits[i].classList.remove("cur"); }
          function unwrapMark(mark){ var p = mark.parentNode; if(!p) return; p.replaceChild(document.createTextNode(mark.textContent), mark); p.normalize(); }

          function clearHighlights(){
            clearCurrent();
            var forced = document.querySelectorAll(".force-show");
            for(var i=0;i<forced.length;i++) forced[i].classList.remove("force-show");
            var main = document.querySelector("main"); if(!main) return;
            var marks = main.querySelectorAll("mark.hit");
            for(var i=marks.length-1;i>=0;i--) unwrapMark(marks[i]);
            __hits = []; __hitIndex = -1;
          }

          function poemContains(poemEl, q){
            if(!poemEl) return false;
            return (poemEl.textContent || "").toLowerCase().indexOf(q) !== -1;
          }

          function applyFilterToPoems(q, filterOn){
            var poems = document.querySelectorAll(".poem");
            for(var i=0;i<poems.length;i++){
              var ok = !filterOn || poemContains(poems[i], q);
              poems[i].classList.toggle("hidden", !ok);
            }
            var tocLinks = document.querySelectorAll("ul.toc a[href^='#']");
            for(var j=0;j<tocLinks.length;j++){
              var href = tocLinks[j].getAttribute("href") || "";
              var id = href.substring(1);
              var target = id ? document.getElementById(id) : null;
              var li = tocLinks[j].closest("li");
              if(li){
                var hidden = target ? target.classList.contains("hidden") : false;
                li.classList.toggle("hidden", hidden);
              }
            }
          }

          function highlightAll(q){
            var main = document.querySelector("main");
            if(!main) return;
            var qq = (q || "").trim(); if(!qq) return;
            var re = new RegExp(escapeRegExp(qq), "gi");
            var walker = document.createTreeWalker(main, NodeFilter.SHOW_TEXT, {
              acceptNode: function(node){
                if(!node || !node.nodeValue || !node.nodeValue.trim()) return NodeFilter.FILTER_REJECT;
                var p = node.parentNode;
                if(!p) return NodeFilter.FILTER_REJECT;
                var tag = (p.nodeName || "").toUpperCase();
                if(tag==="SCRIPT"||tag==="STYLE") return NodeFilter.FILTER_REJECT;
                if(p.closest && p.closest("mark.hit")) return NodeFilter.FILTER_REJECT;
                return NodeFilter.FILTER_ACCEPT;
              }
            }, false);
            var nodes = []; while(walker.nextNode()) nodes.push(walker.currentNode);
            for(var i=0;i<nodes.length;i++){
              var node = nodes[i];
              var text = node.nodeValue;
              re.lastIndex = 0; if(!re.test(text)) continue;
              var frag = document.createDocumentFragment(); var last = 0; var m;
              re.lastIndex = 0;
              while((m = re.exec(text)) !== null){
                if(m.index > last) frag.appendChild(document.createTextNode(text.substring(last, m.index)));
                var mk = document.createElement("mark"); mk.className = "hit"; mk.textContent = m[0];
                frag.appendChild(mk); last = m.index + m[0].length;
                if(m[0].length === 0) re.lastIndex++;
              }
              if(last < text.length) frag.appendChild(document.createTextNode(text.substring(last)));
              node.parentNode.replaceChild(frag, node);
            }
            __hits = Array.prototype.slice.call(main.querySelectorAll("mark.hit"));
          }

          function revealForHits(){
            if(!__hits.length) return;
            for(var i=0;i<__hits.length;i++){
              var h = __hits[i];
              var poem = h.closest(".poem"); if(poem) poem.classList.remove("hidden");
              var note = h.closest(".critnote"); if(note) note.classList.add("force-show");
              var vline = h.closest(".varline"); if(vline) vline.classList.add("force-show");
            }
            var tocLinks = document.querySelectorAll("ul.toc a[href^='#']");
            for(var j=0;j<tocLinks.length;j++){
              var href = tocLinks[j].getAttribute("href") || "";
              var id = href.substring(1);
              var target = document.getElementById(id);
              var li = tocLinks[j].closest("li");
              if(li && target) li.classList.toggle("hidden", target.classList.contains("hidden"));
            }
          }

          function filterVisibleHits(){
            var filtered = [];
            for(var i=0;i<__hits.length;i++){
              if(__hits[i].closest(".variants")) continue;
              filtered.push(__hits[i]);
            }
            __hits = filtered;
          }

          function scrollToHit(idx){
            if(!__hits.length) return;
            if(idx < 0) idx = 0; if(idx >= __hits.length) idx = __hits.length - 1;
            clearCurrent(); __hitIndex = idx;
            var cur = __hits[__hitIndex]; cur.classList.add("cur");
            var poem = cur.closest(".poem");
            if(poem){
               poem.classList.remove("hidden");
               var pid = poem.getAttribute("id"); if(pid) setSelectedPoemById(pid);
            }
            cur.scrollIntoView({behavior:"smooth", block:"center"});
            setMeta("命中 " + (__hitIndex + 1) + " / " + __hits.length);
          }

          function doSearch(){
            var qEl = document.getElementById("q");
            if(!qEl) return;
            var q = (qEl.value || "").trim();
            var filterOn = !!(document.getElementById("optFilter") && document.getElementById("optFilter").checked);
            clearHighlights();
            if(!q){ applyFilterToPoems("", false); setMeta(""); return; }
            applyFilterToPoems(q, filterOn);
            highlightAll(q);
            if(!__hits.length){ setMeta("未找到命中。"); return; }
            revealForHits();
            filterVisibleHits();
            if(!__hits.length){ setMeta("命中出現在異文中（已在下行顯示）。"); return; }
            scrollToHit(0);
          }

          function initSearch(){
            var btnFind = document.getElementById("btnFind");
            if(btnFind) btnFind.addEventListener("click", doSearch);
            var btnNext = document.getElementById("btnNext"); if(btnNext) btnNext.addEventListener("click", function(){ nextHit(); });
            var btnPrev = document.getElementById("btnPrev");
            if(btnPrev) btnPrev.addEventListener("click", function(){ prevHit(); });
            var btnClear= document.getElementById("btnClear");
            if(btnClear) btnClear.addEventListener("click", function(){
              document.getElementById("q").value = ""; clearHighlights(); applyFilterToPoems("", false); setMeta("");
            });
            var qEl = document.getElementById("q");
            if(qEl) qEl.addEventListener("keydown", function(e){ if(e.key === "Enter"){ e.preventDefault(); doSearch(); } });
            var opt = document.getElementById("optFilter");
            if(opt) opt.addEventListener("change", function(){ if(qEl.value.trim()) doSearch(); });
          }
          function nextHit(){ if(__hits.length) scrollToHit(__hitIndex+1 >= __hits.length ? 0 : __hitIndex+1); }
          function prevHit(){ if(__hits.length) scrollToHit(__hitIndex-1 < 0 ? __hits.length-1 : __hitIndex-1); }

          function initUI(){
            var sel = document.getElementById("witView");
            if(sel){ sel.addEventListener("change", function(){ applyView(this.value); }); applyView(sel.value || "main"); }
            var chkNotes = document.getElementById("showNotes");
            if(chkNotes){ chkNotes.addEventListener("change", function(){ applyNotes(this.checked); }); applyNotes(chkNotes.checked); }
            var chkEd = document.getElementById("showEdits");
            if(chkEd){ chkEd.addEventListener("change", function(){ applyEditor(this.checked); }); applyEditor(chkEd.checked); }
            initSearch();
            initPoemSelect();
          }

          document.addEventListener("DOMContentLoaded", initUI);
        ]]></script>
      </head>

      <body data-view="main" data-notes="off" data-editor="off">
        <div class="wrap">
          <nav>
            <h1>
              <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/>
            </h1>

            <div class="ctrl">
              <label>顯示版本 (Witness)</label>
              <select id="witView">
                <option value="main">主讀本 (Main)</option>
                <option value="GX">只看 古香樓抄本</option>
                <option value="MY">只看 眠雲精舍抄本</option>
                <option value="ZQ">只看 振綺堂抄本</option>
                <option value="all">異文對讀</option>
              </select>

              <div class="searchbox">
                <label>搜尋 (Search)</label>
                <input id="q" type="text" placeholder="關鍵詞..."/>
                <div class="searchrow">
                  <button type="button" id="btnFind">搜尋</button>
                  <button type="button" id="btnPrev">上一個</button>
                  <button type="button" id="btnNext">下一個</button>
                  <button type="button" id="btnClear">清除</button>
                </div>
                <div class="searchopt">
                  <label><input type="checkbox" id="optFilter" checked="checked"/> 只顯示命中詩作</label>
                </div>
                <div class="searchmeta" id="searchMeta"></div>
              </div>

              <div class="checkrow">
                <label><input type="checkbox" id="showNotes"/> 顯示注釋 (Notes)</label>
              </div>

              <div class="checkrow">
                <label><input type="checkbox" id="showEdits"/> 顯示編者校改</label>
              </div>
            </div>

            <div class="meta">目錄</div>

            <ul class="toc">
              <xsl:for-each select="tei:text/tei:body/tei:div[@type='poem']">
                <li>
                  <xsl:attribute name="data-poemno"><xsl:value-of select="position()"/></xsl:attribute>
                  <span class="tocnum">
                    <xsl:value-of select="position()"/>
                    <xsl:text>.</xsl:text>
                  </span>
                  <a>
                    <xsl:attribute name="href">
                      <xsl:text>#</xsl:text>
                      <xsl:call-template name="poem-id"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="tei:head/node()"/>
                  </a>
                </li>
              </xsl:for-each>
            </ul>
          </nav>

          <main>
            <div style="background:#f8f9fa; padding:15px; border-bottom:1px solid #ddd; margin-bottom:20px; border-radius:5px;">
               <h1 style="margin-top:0"><xsl:value-of select="//tei:titleStmt/tei:title"/></h1>
               <div style="color:#555; font-size:18pt; margin-bottom: 10px;">
                 <div>作者：<xsl:value-of select="//tei:titleStmt/tei:author/tei:persName | //tei:titleStmt/tei:author"/></div>
                 <div>編者：<xsl:value-of select="//tei:titleStmt/tei:editor[@xml:lang='zh-Hant'] | //tei:titleStmt/tei:editor[1]"/></div>
               </div>
               <div style="color:#444; font-size:16pt; border-top: 1px dashed #ccc; padding-top: 10px;">
                 <strong>各版本信息：</strong>
                 <ul style="margin-top: 5px; padding-left: 20px;">
                   <xsl:for-each select="//tei:sourceDesc/tei:listWit/tei:witness">
                     <li>
                       <strong><xsl:value-of select="tei:abbr"/></strong>:
                       <xsl:value-of select="tei:name[@xml:lang='zh-Hant'] | tei:name[1]"/>
                     </li>
                   </xsl:for-each>
                 </ul>
               </div>
            </div>

            <xsl:apply-templates select="tei:text/tei:front"/>

            <xsl:apply-templates select="tei:text/tei:body | tei:text/tei:back"/>
          </main>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="tei:front">
    <div class="front" style="margin-bottom: 20px; padding: 15px; border: 1px solid #ccc; background: #fffcf0; border-radius: 8px;">
      <h2 style="margin-top:0; font-size:20pt; border-bottom:1px solid #ddd; padding-bottom:5px;">序文</h2>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:body">
    <xsl:for-each select="tei:div[@type='poem']">
      <div class="poem">
        <xsl:attribute name="id"><xsl:call-template name="poem-id"/></xsl:attribute>
        <xsl:attribute name="data-poemno"><xsl:value-of select="position()"/></xsl:attribute>

        <div class="poem-title">
          <xsl:apply-templates select="tei:head/node()"/>
        </div>

        <xsl:apply-templates select="*[not(self::tei:head)]"/>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:back">
    <div class="back">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:lg">
    <div class="lg">
      <xsl:apply-templates select="tei:l"/>
    </div>
  </xsl:template>

  <xsl:template match="tei:l">
    <xsl:variable name="lineHasDiff"
      select="count(.//tei:app[tei:rdg[not(contains(@ana, '#agree')) and (normalize-space(string(.))!='' or * or @ana) and normalize-space(string(.)) != normalize-space(string(../tei:lem))]])"/>

    <div class="l">
      <xsl:apply-templates/>

      <xsl:if test="$lineHasDiff &gt; 0">
         <span class="lem-wit-note">
           <xsl:text> （主讀來自：</xsl:text>
           <xsl:variable name="lemWits">
             <xsl:value-of select=".//tei:app[1]/tei:lem/@wit"/>
             <xsl:text> </xsl:text>
             <xsl:for-each select=".//tei:app[1]/tei:rdg[contains(@ana, '#agree')]">
               <xsl:value-of select="@wit"/>
               <xsl:text> </xsl:text>
             </xsl:for-each>
           </xsl:variable>
           <xsl:call-template name="wit-label-list">
             <xsl:with-param name="wits" select="$lemWits"/>
           </xsl:call-template>
           <xsl:text>）</xsl:text>
         </span>
      </xsl:if>
    </div>

    <xsl:if test="$lineHasDiff &gt; 0">
      <div class="varline">
        <span class="tag">異文</span>

        <xsl:for-each select=".//tei:rdg[
          not(contains(@ana, '#agree')) and
          (normalize-space(string(.)) != '' or * or @ana) and
          normalize-space(string(.)) != normalize-space(string(../tei:lem)) and
          generate-id() = generate-id(
            key('kRdgText', concat(generate-id(..), '|', normalize-space(string(.))))[1]
          )
        ]">

          <xsl:variable name="sharedWits">
             <xsl:for-each select="key('kRdgText', concat(generate-id(..), '|', normalize-space(string(.))))">
                <xsl:value-of select="@wit"/>
                <xsl:text> </xsl:text>
             </xsl:for-each>
          </xsl:variable>

          <xsl:variable name="wRaw" select="normalize-space(translate(@wit,'#',''))"/>

          <div class="item" style="color: #5e35b1; font-size: 0.85em; padding-left: 10px; border-left: 2px solid #ddd;">
            <span class="rdgtext">
               <xsl:for-each select="ancestor::tei:l[1]/node()">
                  <xsl:choose>
                     <xsl:when test="self::tei:app">
                        <xsl:variable name="targetRdg" select="tei:rdg[contains(translate(@wit,'#',''), $wRaw)]"/>
                        <xsl:choose>
                           <xsl:when test="$targetRdg and not(contains($targetRdg/@ana, '#agree'))">
                              <span class="diff">
                                 <xsl:apply-templates select="$targetRdg/node()"/>
                              </span>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:apply-templates select="tei:lem/node()"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:when>
                     <xsl:otherwise><xsl:apply-templates select="."/></xsl:otherwise>
                  </xsl:choose>
               </xsl:for-each>
            </span>

            <xsl:text> （來自：</xsl:text>
            <xsl:call-template name="wit-label-list">
              <xsl:with-param name="wits" select="$sharedWits"/>
            </xsl:call-template>
            <xsl:text>）</xsl:text>
          </div>
        </xsl:for-each>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:head//tei:app">
    <xsl:variable name="lemText" select="normalize-space(string(tei:lem))"/>
    <xsl:variable name="hasDiff" select="count(tei:rdg[not(contains(@ana, '#agree')) and normalize-space(string(.)) != $lemText])"/>

    <span class="app">
      <xsl:attribute name="data-hasdiff">
        <xsl:choose>
          <xsl:when test="$hasDiff &gt; 0">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <span class="chosen">
        <xsl:apply-templates select="tei:lem/node()"/>
      </span>

      <span class="variants" style="display:none;">
        <span class="lem">
          <xsl:attribute name="data-wits">
            <xsl:call-template name="wit-normalize">
              <xsl:with-param name="wit" select="tei:lem/@wit"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="tei:lem/node()"/>
        </span>

        <xsl:for-each select="tei:rdg[normalize-space(string(.)) != '' or * or @ana]">
          <span class="rdg">
            <xsl:attribute name="data-wits">
              <xsl:call-template name="wit-normalize">
                <xsl:with-param name="wit" select="@wit"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="contains(@ana, '#agree')">
                <xsl:apply-templates select="../tei:lem/node()"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
              </xsl:otherwise>
            </xsl:choose>
          </span>
        </xsl:for-each>
      </span>

      <xsl:if test="$hasDiff &gt; 0">
        <span class="headvars" style="display:none; font-weight:normal; font-size:0.85em; color:#d63384;">
          <xsl:text> （主讀來自：</xsl:text>
          <xsl:variable name="lemWits">
            <xsl:value-of select="tei:lem/@wit"/>
            <xsl:text> </xsl:text>
            <xsl:for-each select="tei:rdg[contains(@ana, '#agree')]">
              <xsl:value-of select="@wit"/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
          </xsl:variable>
          <xsl:call-template name="wit-label-list">
            <xsl:with-param name="wits" select="$lemWits"/>
          </xsl:call-template>
          <xsl:text>；</xsl:text>

          <xsl:for-each select="tei:rdg[
              not(contains(@ana, '#agree')) and
              normalize-space(string(.)) != $lemText and
              generate-id() = generate-id(
                key('kRdgText', concat(generate-id(..), '|', normalize-space(string(.))))[1]
              )
          ]">
            <xsl:if test="position() &gt; 1"><xsl:text>；</xsl:text></xsl:if>
            <xsl:variable name="sharedWits">
              <xsl:for-each select="key('kRdgText', concat(generate-id(..), '|', normalize-space(string(.))))">
                <xsl:value-of select="@wit"/>
                <xsl:text> </xsl:text>
              </xsl:for-each>
            </xsl:variable>

            <xsl:text>異文作「</xsl:text>
            <span class="diff"><xsl:apply-templates select="node()"/></span>
            <xsl:text>」來自：</xsl:text>
            <xsl:call-template name="wit-label-list">
              <xsl:with-param name="wits" select="$sharedWits"/>
            </xsl:call-template>
          </xsl:for-each>
          <xsl:text>）</xsl:text>
        </span>
      </xsl:if>
    </span>
  </xsl:template>

  <xsl:template match="tei:app">
    <xsl:variable name="lemText" select="normalize-space(string(tei:lem))"/>
    <xsl:variable name="hasDiff" select="count(tei:rdg[not(contains(@ana, '#agree')) and (normalize-space(string(.))!='' or * or @ana) and normalize-space(string(.)) != $lemText])"/>

    <span class="app">
      <xsl:attribute name="data-hasdiff">
        <xsl:choose>
          <xsl:when test="$hasDiff &gt; 0">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <span class="chosen">
        <xsl:apply-templates select="tei:lem/node()"/>
      </span>

      <span class="variants">
        <span class="lem">
          <xsl:attribute name="data-wits">
            <xsl:call-template name="wit-normalize">
              <xsl:with-param name="wit" select="tei:lem/@wit"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="tei:lem/node()"/>
        </span>

        <xsl:for-each select="tei:rdg[normalize-space(string(.)) != '' or * or @ana]">
          <span class="rdg">
            <xsl:attribute name="data-wits">
              <xsl:call-template name="wit-normalize">
                <xsl:with-param name="wit" select="@wit"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="contains(@ana, '#agree')">
                <xsl:apply-templates select="../tei:lem/node()"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
              </xsl:otherwise>
            </xsl:choose>
          </span>
        </xsl:for-each>
      </span>
    </span>
  </xsl:template>

  <xsl:template match="tei:trailer">
    <div class="trailer">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:note">
    <div>
      <xsl:attribute name="class">
        <xsl:text>critnote</xsl:text>
        <xsl:if test="@target"> headnote</xsl:if>
        <xsl:if test="@subtype='seal'"> seal</xsl:if>
      </xsl:attribute>
      <xsl:if test="@target">
        <xsl:attribute name="data-target"><xsl:value-of select="@target"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:hi | tei:seg">
    <span>
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="@rend='small'">rend-small</xsl:when>
          <xsl:when test="@rend='big' or @rend='large'">rend-big</xsl:when>
          <xsl:when test="@rend='sup' or @rend='upper'">rend-sup</xsl:when>
          <xsl:when test="@rend='sub' or @rend='lower'">rend-sub</xsl:when>
          <xsl:when test="@rend='bold'">rend-bold</xsl:when>
          <xsl:when test="@rend='italic'">rend-italic</xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <xsl:if test="@rend='small' or @rend='big' or @rend='large'">
        <xsl:attribute name="title">
          <xsl:text>標註原因：</xsl:text>
          <xsl:text>rend=</xsl:text><xsl:value-of select="@rend"/>
          <xsl:if test="@type"><xsl:text>; type=</xsl:text><xsl:value-of select="@type"/></xsl:if>
          <xsl:if test="@subtype"><xsl:text>; subtype=</xsl:text><xsl:value-of select="@subtype"/></xsl:if>
          <xsl:if test="@ana"><xsl:text>; ana=</xsl:text><xsl:value-of select="@ana"/></xsl:if>
          <xsl:if test="@corresp"><xsl:text>; corresp=</xsl:text><xsl:value-of select="@corresp"/></xsl:if>
          <xsl:if test="@resp"><xsl:text>; resp=</xsl:text><xsl:value-of select="@resp"/></xsl:if>
        </xsl:attribute>
      </xsl:if>

      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:del">
    <span>
      <xsl:attribute name="class">
        <xsl:text>del</xsl:text>
        <xsl:if test="@rend='small'"><xsl:text> rend-small</xsl:text></xsl:if>
        <xsl:if test="@rend='big' or @rend='large'"><xsl:text> rend-big</xsl:text></xsl:if>
        <xsl:if test="@rend='sup' or @rend='upper'"><xsl:text> rend-sup</xsl:text></xsl:if>
        <xsl:if test="@rend='sub' or @rend='lower'"><xsl:text> rend-sub</xsl:text></xsl:if>
        <xsl:if test="@rend='bold'"><xsl:text> rend-bold</xsl:text></xsl:if>
        <xsl:if test="@rend='italic'"><xsl:text> rend-italic</xsl:text></xsl:if>
      </xsl:attribute>

      <xsl:if test="@rend='small' or @rend='big' or @rend='large'">
        <xsl:attribute name="title">
          <xsl:text>標註原因：</xsl:text>
          <xsl:text>rend=</xsl:text><xsl:value-of select="@rend"/>
          <xsl:if test="@type"><xsl:text>; type=</xsl:text><xsl:value-of select="@type"/></xsl:if>
          <xsl:if test="@subtype"><xsl:text>; subtype=</xsl:text><xsl:value-of select="@subtype"/></xsl:if>
          <xsl:if test="@ana"><xsl:text>; ana=</xsl:text><xsl:value-of select="@ana"/></xsl:if>
          <xsl:if test="@corresp"><xsl:text>; corresp=</xsl:text><xsl:value-of select="@corresp"/></xsl:if>
          <xsl:if test="@resp"><xsl:text>; resp=</xsl:text><xsl:value-of select="@resp"/></xsl:if>
        </xsl:attribute>
      </xsl:if>

      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:add">
    <span>
      <xsl:attribute name="class">
        <xsl:text>add</xsl:text>
        <xsl:if test="@rend='small'"><xsl:text> rend-small</xsl:text></xsl:if>
        <xsl:if test="@rend='big' or @rend='large'"><xsl:text> rend-big</xsl:text></xsl:if>
        <xsl:if test="@rend='sup' or @rend='upper'"><xsl:text> rend-sup</xsl:text></xsl:if>
        <xsl:if test="@rend='sub' or @rend='lower'"><xsl:text> rend-sub</xsl:text></xsl:if>
        <xsl:if test="@rend='bold'"><xsl:text> rend-bold</xsl:text></xsl:if>
        <xsl:if test="@rend='italic'"><xsl:text> rend-italic</xsl:text></xsl:if>
      </xsl:attribute>

      <xsl:if test="@rend='small' or @rend='big' or @rend='large'">
        <xsl:attribute name="title">
          <xsl:text>標註原因：</xsl:text>
          <xsl:text>rend=</xsl:text><xsl:value-of select="@rend"/>
          <xsl:if test="@type"><xsl:text>; type=</xsl:text><xsl:value-of select="@type"/></xsl:if>
          <xsl:if test="@subtype"><xsl:text>; subtype=</xsl:text><xsl:value-of select="@subtype"/></xsl:if>
          <xsl:if test="@ana"><xsl:text>; ana=</xsl:text><xsl:value-of select="@ana"/></xsl:if>
          <xsl:if test="@corresp"><xsl:text>; corresp=</xsl:text><xsl:value-of select="@corresp"/></xsl:if>
          <xsl:if test="@resp"><xsl:text>; resp=</xsl:text><xsl:value-of select="@resp"/></xsl:if>
        </xsl:attribute>
      </xsl:if>

      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:subst"><xsl:apply-templates/></xsl:template>

  <xsl:template match="tei:gap">
    <span class="gap">
      <xsl:choose>
        <xsl:when test="@quantity and (@unit='char' or @unit='chars' or not(@unit))">
          <xsl:call-template name="repeat-square">
            <xsl:with-param name="n" select="@quantity"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise><xsl:text>□</xsl:text></xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template match="tei:choice[tei:corr and tei:sic]">
    <span class="choice">
      <span class="sic"><xsl:apply-templates select="tei:sic/node()"/></span>
      <span class="corr"><xsl:apply-templates select="tei:corr/node()"/></span>
    </span>
  </xsl:template>

  <xsl:template match="tei:choice[tei:orig and tei:reg]">
    <span class="choice">
      <span class="sic"><xsl:apply-templates select="tei:orig/node()"/></span>
      <span class="corr"><xsl:apply-templates select="tei:reg/node()"/></span>
    </span>
  </xsl:template>

  <xsl:template match="tei:choice"><xsl:apply-templates/></xsl:template>

  <xsl:template match="tei:unclear">
    <span class="unclear">
      <xsl:if test="@reason or @cert">
        <xsl:attribute name="title">
          <xsl:text>字跡模糊</xsl:text>
          <xsl:if test="@reason">；原因：<xsl:value-of select="@reason"/></xsl:if>
          <xsl:if test="@cert">；確信度：<xsl:value-of select="@cert"/></xsl:if>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:damage">
    <span class="damage">
      <xsl:attribute name="title">
        <xsl:text>文獻破損</xsl:text>
        <xsl:if test="@extent">；範圍：<xsl:value-of select="@extent"/></xsl:if>
        <xsl:if test="@agent">；因素：<xsl:value-of select="@agent"/></xsl:if>
      </xsl:attribute>
      <xsl:text>【破損】</xsl:text>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:g">
    <span class="gaiji">
      <xsl:attribute name="title">
        <xsl:text>正規字：</xsl:text><xsl:value-of select="@norm"/>
        <xsl:text> (來源：</xsl:text><xsl:value-of select="@ref"/><xsl:text>)</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:pc">
    <span class="punct">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:lb"><br/></xsl:template>
  <xsl:template match="tei:pb"><br/></xsl:template>
  <xsl:template match="tei:p"><p><xsl:apply-templates/></p></xsl:template>

  <xsl:template match="tei:ref">
    <a href="{@target}" style="color:#0056b3;">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:stylesheet>
