# frozen_string_literal: true

module Dragnet
  module DOM
    module HTMLStandardTags
      extend Tags

      # @!method a(**attributes, &content)
      # 	Outputs an `<a>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/a
      register_tag :a, tag: "a"

      # @!method abbr(**attributes, &content)
      # 	Outputs an `<abbr>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/abbr
      register_tag :abbr, tag: "abbr"

      # @!method address(**attributes, &content)
      # 	Outputs an `<address>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/address
      register_tag :address, tag: "address"

      # @!method article(**attributes, &content)
      # 	Outputs an `<article>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/article
      register_tag :article, tag: "article"

      # @!method aside(**attributes, &content)
      # 	Outputs an `<aside>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/aside
      register_tag :aside, tag: "aside"

      # @!method b(**attributes, &content)
      # 	Outputs a `<b>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/b
      register_tag :b, tag: "b"

      # @!method bdi(**attributes, &content)
      # 	Outputs a `<bdi>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/bdi
      register_tag :bdi, tag: "bdi"

      # @!method bdo(**attributes, &content)
      # 	Outputs a `<bdo>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/bdo
      register_tag :bdo, tag: "bdo"

      # @!method blockquote(**attributes, &content)
      # 	Outputs a `<blockquote>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/blockquote
      register_tag :blockquote, tag: "blockquote"

      # @!method body(**attributes, &content)
      # 	Outputs a `<body>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/body
      register_tag :body, tag: "body"

      # @!method button(**attributes, &content)
      # 	Outputs a `<button>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/button
      register_tag :button, tag: "button"

      # @!method canvas(**attributes, &content)
      # 	Outputs a `<canvas>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/canvas
      register_tag :canvas, tag: "canvas"

      # @!method caption(**attributes, &content)
      # 	Outputs a `<caption>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/caption
      register_tag :caption, tag: "caption"

      # @!method cite(**attributes, &content)
      # 	Outputs a `<cite>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/cite
      register_tag :cite, tag: "cite"

      # @!method code(**attributes, &content)
      # 	Outputs a `<code>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/code
      register_tag :code, tag: "code"

      # @!method colgroup(**attributes, &content)
      # 	Outputs a `<colgroup>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/colgroup
      register_tag :colgroup, tag: "colgroup"

      # @!method data(**attributes, &content)
      # 	Outputs a `<data>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/data
      register_tag :data, tag: "data"

      # @!method datalist(**attributes, &content)
      # 	Outputs a `<datalist>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/datalist
      register_tag :datalist, tag: "datalist"

      # @!method dd(**attributes, &content)
      # 	Outputs a `<dd>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/dd
      register_tag :dd, tag: "dd"

      # @!method del(**attributes, &content)
      # 	Outputs a `<del>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/del
      register_tag :del, tag: "del"

      # @!method details(**attributes, &content)
      # 	Outputs a `<details>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/details
      register_tag :details, tag: "details"

      # @!method dfn(**attributes, &content)
      # 	Outputs a `<dfn>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/dfn
      register_tag :dfn, tag: "dfn"

      # @!method dialog(**attributes, &content)
      # 	Outputs a `<dialog>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/dialog
      register_tag :dialog, tag: "dialog"

      # @!method div(**attributes, &content)
      # 	Outputs a `<div>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/div
      register_tag :div, tag: "div"

      # @!method dl(**attributes, &content)
      # 	Outputs a `<dl>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/dl
      register_tag :dl, tag: "dl"

      # @!method dt(**attributes, &content)
      # 	Outputs a `<dt>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/dt
      register_tag :dt, tag: "dt"

      # @!method em(**attributes, &content)
      # 	Outputs an `<em>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/em
      register_tag :em, tag: "em"

      # @!method fieldset(**attributes, &content)
      # 	Outputs a `<fieldset>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/fieldset
      register_tag :fieldset, tag: "fieldset"

      # @!method figcaption(**attributes, &content)
      # 	Outputs a `<figcaption>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/figcaption
      register_tag :figcaption, tag: "figcaption"

      # @!method figure(**attributes, &content)
      # 	Outputs a `<figure>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/figure
      register_tag :figure, tag: "figure"

      # @!method footer(**attributes, &content)
      # 	Outputs a `<footer>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/footer
      register_tag :footer, tag: "footer"

      # @!method form(**attributes, &content)
      # 	Outputs a `<form>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/form
      register_tag :form, tag: "form"

      # @!method h1(**attributes, &content)
      # 	Outputs an `<h1>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/h1
      register_tag :h1, tag: "h1"

      # @!method h2(**attributes, &content)
      # 	Outputs an `<h2>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/h2
      register_tag :h2, tag: "h2"

      # @!method h3(**attributes, &content)
      # 	Outputs an `<h3>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/h3
      register_tag :h3, tag: "h3"

      # @!method h4(**attributes, &content)
      # 	Outputs an `<h4>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/h4
      register_tag :h4, tag: "h4"

      # @!method h5(**attributes, &content)
      # 	Outputs an `<h5>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/h5
      register_tag :h5, tag: "h5"

      # @!method h6(**attributes, &content)
      # 	Outputs an `<h6>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/h6
      register_tag :h6, tag: "h6"

      # @!method head(**attributes, &content)
      # 	Outputs a `<head>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/head
      register_tag :head, tag: "head"

      # @!method header(**attributes, &content)
      # 	Outputs a `<header>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/header
      register_tag :header, tag: "header"

      # @!method hgroup(**attributes, &content)
      # 	Outputs an `<hgroup>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/hgroup
      register_tag :hgroup, tag: "hgroup"

      # @!method html(**attributes, &content)
      # 	Outputs an `<html>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/html
      register_tag :html, tag: "html"

      # @!method i(**attributes, &content)
      # 	Outputs an `<i>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/i
      register_tag :i, tag: "i"

      # @!method iframe(**attributes, &content)
      # 	Outputs an `<iframe>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/iframe
      register_tag :iframe, tag: "iframe"

      # @!method ins(**attributes, &content)
      # 	Outputs an `<ins>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/ins
      register_tag :ins, tag: "ins"

      # @!method kbd(**attributes, &content)
      # 	Outputs a `<kbd>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/kbd
      register_tag :kbd, tag: "kbd"

      # @!method label(**attributes, &content)
      # 	Outputs a `<label>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/label
      register_tag :label, tag: "label"

      # @!method legend(**attributes, &content)
      # 	Outputs a `<legend>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/legend
      register_tag :legend, tag: "legend"

      # @!method li(**attributes, &content)
      # 	Outputs a `<li>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/li
      register_tag :li, tag: "li"

      # @!method main(**attributes, &content)
      # 	Outputs a `<main>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/main
      register_tag :main, tag: "main"

      # @!method map(**attributes, &content)
      # 	Outputs a `<map>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/map
      register_tag :map, tag: "map"

      # @!method mark(**attributes, &content)
      # 	Outputs a `<mark>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/mark
      register_tag :mark, tag: "mark"

      # @!method meter(**attributes, &content)
      # 	Outputs a `<meter>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/meter
      register_tag :meter, tag: "meter"

      # @!method nav(**attributes, &content)
      # 	Outputs a `<nav>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/nav
      register_tag :nav, tag: "nav"

      # @!method noscript(**attributes, &content)
      # 	Outputs a `<noscript>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/noscript
      register_tag :noscript, tag: "noscript"

      # @!method object(**attributes, &content)
      # 	Outputs an `<object>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/object
      register_tag :object, tag: "object"

      # @!method ol(**attributes, &content)
      # 	Outputs an `<ol>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/ol
      register_tag :ol, tag: "ol"

      # @!method optgroup(**attributes, &content)
      # 	Outputs an `<optgroup>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/optgroup
      register_tag :optgroup, tag: "optgroup"

      # @!method option(**attributes, &content)
      # 	Outputs an `<option>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/option
      register_tag :option, tag: "option"

      # @!method output(**attributes, &content)
      # 	Outputs an `<output>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/output
      register_tag :output, tag: "output"

      # @!method p(**attributes, &content)
      # 	Outputs a `<p>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/p
      register_tag :p, tag: "p"

      # @!method picture(**attributes, &content)
      # 	Outputs a `<picture>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/picture
      register_tag :picture, tag: "picture"

      # @!method pre(**attributes, &content)
      # 	Outputs a `<pre>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/pre
      register_tag :pre, tag: "pre"

      # @!method progress(**attributes, &content)
      # 	Outputs a `<progress>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/progress
      register_tag :progress, tag: "progress"

      # @!method q(**attributes, &content)
      # 	Outputs a `<q>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/q
      register_tag :q, tag: "q"

      # @!method rp(**attributes, &content)
      # 	Outputs an `<rp>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/rp
      register_tag :rp, tag: "rp"

      # @!method rt(**attributes, &content)
      # 	Outputs an `<rt>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/rt
      register_tag :rt, tag: "rt"

      # @!method ruby(**attributes, &content)
      # 	Outputs a `<ruby>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/ruby
      register_tag :ruby, tag: "ruby"

      # @!method s(**attributes, &content)
      # 	Outputs an `<s>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/s
      register_tag :s, tag: "s"

      # @!method samp(**attributes, &content)
      # 	Outputs a `<samp>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/samp
      register_tag :samp, tag: "samp"

      # @!method script(**attributes, &content)
      # 	Outputs a `<script>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/script
      register_tag :script, tag: "script"

      # @!method section(**attributes, &content)
      # 	Outputs a `<section>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/section
      register_tag :section, tag: "section"

      # @!method select(**attributes, &content)
      # 	Outputs a `<select>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/select
      register_tag :select, tag: "select"

      # @!method slot(**attributes, &content)
      # 	Outputs a `<slot>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/slot
      register_tag :slot, tag: "slot"

      # @!method small(**attributes, &content)
      # 	Outputs a `<small>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/small
      register_tag :small, tag: "small"

      # @!method span(**attributes, &content)
      # 	Outputs a `<span>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/span
      register_tag :span, tag: "span"

      # @!method strong(**attributes, &content)
      # 	Outputs a `<strong>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/strong
      register_tag :strong, tag: "strong"

      # @!method style(**attributes, &content)
      # 	Outputs a `<style>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/style
      register_tag :style, tag: "style"

      # @!method sub(**attributes, &content)
      # 	Outputs a `<sub>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/sub
      register_tag :sub, tag: "sub"

      # @!method summary(**attributes, &content)
      # 	Outputs a `<summary>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/summary
      register_tag :summary, tag: "summary"

      # @!method sup(**attributes, &content)
      # 	Outputs a `<sup>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/sup
      register_tag :sup, tag: "sup"

      # @!method svg(**attributes, &content)
      # 	Outputs an `<svg>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/en-US/docs/Web/SVG/Element/svg
      register_tag :svg, tag: "svg"

      # @!method table(**attributes, &content)
      # 	Outputs a `<table>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/table
      register_tag :table, tag: "table"

      # @!method tbody(**attributes, &content)
      # 	Outputs a `<tbody>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/tbody
      register_tag :tbody, tag: "tbody"

      # @!method td(**attributes, &content)
      # 	Outputs a `<td>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/td
      register_tag :td, tag: "td"

      # @!method template_tag(**attributes, &content)
      # 	Outputs a `<template>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/template
      register_tag :template_tag, tag: "template"

      # @!method textarea(**attributes, &content)
      # 	Outputs a `<textarea>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/textarea
      register_tag :textarea, tag: "textarea"

      # @!method tfoot(**attributes, &content)
      # 	Outputs a `<tfoot>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/tfoot
      register_tag :tfoot, tag: "tfoot"

      # @!method th(**attributes, &content)
      # 	Outputs a `<th>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/th
      register_tag :th, tag: "th"

      # @!method thead(**attributes, &content)
      # 	Outputs a `<thead>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/thead
      register_tag :thead, tag: "thead"

      # @!method time(**attributes, &content)
      # 	Outputs a `<time>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/time
      register_tag :time, tag: "time"

      # @!method title(**attributes, &content)
      # 	Outputs a `<title>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/title
      register_tag :title, tag: "title"

      # @!method tr(**attributes, &content)
      # 	Outputs a `<tr>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/tr
      register_tag :tr, tag: "tr"

      # @!method u(**attributes, &content)
      # 	Outputs a `<u>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/u
      register_tag :u, tag: "u"

      # @!method ul(**attributes, &content)
      # 	Outputs a `<ul>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/ul
      register_tag :ul, tag: "ul"

      # @!method video(**attributes, &content)
      # 	Outputs a `<video>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/video
      register_tag :video, tag: "video"

      # @!method wbr(**attributes, &content)
      # 	Outputs a `<wbr>` tag.
      # 	@return [HTMLElement]
      # 	@yieldparam component [self]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/wbr
      register_tag :wbr, tag: "wbr"
    end
  end
end
