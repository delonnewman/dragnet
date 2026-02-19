// node_modules/@lit/reactive-element/development/css-tag.js
var NODE_MODE = false;
var global = globalThis;
var supportsAdoptingStyleSheets = global.ShadowRoot && (global.ShadyCSS === undefined || global.ShadyCSS.nativeShadow) && "adoptedStyleSheets" in Document.prototype && "replace" in CSSStyleSheet.prototype;
var constructionToken = Symbol();
var cssTagCache = new WeakMap;

class CSSResult {
  constructor(cssText, strings, safeToken) {
    this["_$cssResult$"] = true;
    if (safeToken !== constructionToken) {
      throw new Error("CSSResult is not constructable. Use `unsafeCSS` or `css` instead.");
    }
    this.cssText = cssText;
    this._strings = strings;
  }
  get styleSheet() {
    let styleSheet = this._styleSheet;
    const strings = this._strings;
    if (supportsAdoptingStyleSheets && styleSheet === undefined) {
      const cacheable = strings !== undefined && strings.length === 1;
      if (cacheable) {
        styleSheet = cssTagCache.get(strings);
      }
      if (styleSheet === undefined) {
        (this._styleSheet = styleSheet = new CSSStyleSheet).replaceSync(this.cssText);
        if (cacheable) {
          cssTagCache.set(strings, styleSheet);
        }
      }
    }
    return styleSheet;
  }
  toString() {
    return this.cssText;
  }
}
var textFromCSSResult = (value) => {
  if (value["_$cssResult$"] === true) {
    return value.cssText;
  } else if (typeof value === "number") {
    return value;
  } else {
    throw new Error(`Value passed to 'css' function must be a 'css' function result: ` + `${value}. Use 'unsafeCSS' to pass non-literal values, but take care ` + `to ensure page security.`);
  }
};
var unsafeCSS = (value) => new CSSResult(typeof value === "string" ? value : String(value), undefined, constructionToken);
var css = (strings, ...values) => {
  const cssText = strings.length === 1 ? strings[0] : values.reduce((acc, v, idx) => acc + textFromCSSResult(v) + strings[idx + 1], strings[0]);
  return new CSSResult(cssText, strings, constructionToken);
};
var adoptStyles = (renderRoot, styles) => {
  if (supportsAdoptingStyleSheets) {
    renderRoot.adoptedStyleSheets = styles.map((s) => s instanceof CSSStyleSheet ? s : s.styleSheet);
  } else {
    for (const s of styles) {
      const style = document.createElement("style");
      const nonce = global["litNonce"];
      if (nonce !== undefined) {
        style.setAttribute("nonce", nonce);
      }
      style.textContent = s.cssText;
      renderRoot.appendChild(style);
    }
  }
};
var cssResultFromStyleSheet = (sheet) => {
  let cssText = "";
  for (const rule of sheet.cssRules) {
    cssText += rule.cssText;
  }
  return unsafeCSS(cssText);
};
var getCompatibleStyle = supportsAdoptingStyleSheets || NODE_MODE && global.CSSStyleSheet === undefined ? (s) => s : (s) => s instanceof CSSStyleSheet ? cssResultFromStyleSheet(s) : s;

// node_modules/@lit/reactive-element/development/reactive-element.js
var { is, defineProperty, getOwnPropertyDescriptor, getOwnPropertyNames, getOwnPropertySymbols, getPrototypeOf } = Object;
var NODE_MODE2 = false;
var global2 = globalThis;
if (NODE_MODE2) {
  global2.customElements ??= customElements;
}
var DEV_MODE = true;
var issueWarning;
var trustedTypes = global2.trustedTypes;
var emptyStringForBooleanAttribute = trustedTypes ? trustedTypes.emptyScript : "";
var polyfillSupport = DEV_MODE ? global2.reactiveElementPolyfillSupportDevMode : global2.reactiveElementPolyfillSupport;
if (DEV_MODE) {
  global2.litIssuedWarnings ??= new Set;
  issueWarning = (code, warning) => {
    warning += ` See https://lit.dev/msg/${code} for more information.`;
    if (!global2.litIssuedWarnings.has(warning) && !global2.litIssuedWarnings.has(code)) {
      console.warn(warning);
      global2.litIssuedWarnings.add(warning);
    }
  };
  queueMicrotask(() => {
    issueWarning("dev-mode", `Lit is in dev mode. Not recommended for production!`);
    if (global2.ShadyDOM?.inUse && polyfillSupport === undefined) {
      issueWarning("polyfill-support-missing", `Shadow DOM is being polyfilled via \`ShadyDOM\` but ` + `the \`polyfill-support\` module has not been loaded.`);
    }
  });
}
var debugLogEvent = DEV_MODE ? (event) => {
  const shouldEmit = global2.emitLitDebugLogEvents;
  if (!shouldEmit) {
    return;
  }
  global2.dispatchEvent(new CustomEvent("lit-debug", {
    detail: event
  }));
} : undefined;
var JSCompiler_renameProperty = (prop, _obj) => prop;
var defaultConverter = {
  toAttribute(value, type) {
    switch (type) {
      case Boolean:
        value = value ? emptyStringForBooleanAttribute : null;
        break;
      case Object:
      case Array:
        value = value == null ? value : JSON.stringify(value);
        break;
    }
    return value;
  },
  fromAttribute(value, type) {
    let fromValue = value;
    switch (type) {
      case Boolean:
        fromValue = value !== null;
        break;
      case Number:
        fromValue = value === null ? null : Number(value);
        break;
      case Object:
      case Array:
        try {
          fromValue = JSON.parse(value);
        } catch (e) {
          fromValue = null;
        }
        break;
    }
    return fromValue;
  }
};
var notEqual = (value, old) => !is(value, old);
var defaultPropertyDeclaration = {
  attribute: true,
  type: String,
  converter: defaultConverter,
  reflect: false,
  useDefault: false,
  hasChanged: notEqual
};
Symbol.metadata ??= Symbol("metadata");
global2.litPropertyMetadata ??= new WeakMap;

class ReactiveElement extends HTMLElement {
  static addInitializer(initializer) {
    this.__prepare();
    (this._initializers ??= []).push(initializer);
  }
  static get observedAttributes() {
    this.finalize();
    return this.__attributeToPropertyMap && [...this.__attributeToPropertyMap.keys()];
  }
  static createProperty(name, options = defaultPropertyDeclaration) {
    if (options.state) {
      options.attribute = false;
    }
    this.__prepare();
    if (this.prototype.hasOwnProperty(name)) {
      options = Object.create(options);
      options.wrapped = true;
    }
    this.elementProperties.set(name, options);
    if (!options.noAccessor) {
      const key = DEV_MODE ? Symbol.for(`${String(name)} (@property() cache)`) : Symbol();
      const descriptor = this.getPropertyDescriptor(name, key, options);
      if (descriptor !== undefined) {
        defineProperty(this.prototype, name, descriptor);
      }
    }
  }
  static getPropertyDescriptor(name, key, options) {
    const { get, set } = getOwnPropertyDescriptor(this.prototype, name) ?? {
      get() {
        return this[key];
      },
      set(v) {
        this[key] = v;
      }
    };
    if (DEV_MODE && get == null) {
      if ("value" in (getOwnPropertyDescriptor(this.prototype, name) ?? {})) {
        throw new Error(`Field ${JSON.stringify(String(name))} on ` + `${this.name} was declared as a reactive property ` + `but it's actually declared as a value on the prototype. ` + `Usually this is due to using @property or @state on a method.`);
      }
      issueWarning("reactive-property-without-getter", `Field ${JSON.stringify(String(name))} on ` + `${this.name} was declared as a reactive property ` + `but it does not have a getter. This will be an error in a ` + `future version of Lit.`);
    }
    return {
      get,
      set(value) {
        const oldValue = get?.call(this);
        set?.call(this, value);
        this.requestUpdate(name, oldValue, options);
      },
      configurable: true,
      enumerable: true
    };
  }
  static getPropertyOptions(name) {
    return this.elementProperties.get(name) ?? defaultPropertyDeclaration;
  }
  static __prepare() {
    if (this.hasOwnProperty(JSCompiler_renameProperty("elementProperties", this))) {
      return;
    }
    const superCtor = getPrototypeOf(this);
    superCtor.finalize();
    if (superCtor._initializers !== undefined) {
      this._initializers = [...superCtor._initializers];
    }
    this.elementProperties = new Map(superCtor.elementProperties);
  }
  static finalize() {
    if (this.hasOwnProperty(JSCompiler_renameProperty("finalized", this))) {
      return;
    }
    this.finalized = true;
    this.__prepare();
    if (this.hasOwnProperty(JSCompiler_renameProperty("properties", this))) {
      const props = this.properties;
      const propKeys = [
        ...getOwnPropertyNames(props),
        ...getOwnPropertySymbols(props)
      ];
      for (const p of propKeys) {
        this.createProperty(p, props[p]);
      }
    }
    const metadata = this[Symbol.metadata];
    if (metadata !== null) {
      const properties = litPropertyMetadata.get(metadata);
      if (properties !== undefined) {
        for (const [p, options] of properties) {
          this.elementProperties.set(p, options);
        }
      }
    }
    this.__attributeToPropertyMap = new Map;
    for (const [p, options] of this.elementProperties) {
      const attr = this.__attributeNameForProperty(p, options);
      if (attr !== undefined) {
        this.__attributeToPropertyMap.set(attr, p);
      }
    }
    this.elementStyles = this.finalizeStyles(this.styles);
    if (DEV_MODE) {
      if (this.hasOwnProperty("createProperty")) {
        issueWarning("no-override-create-property", "Overriding ReactiveElement.createProperty() is deprecated. " + "The override will not be called with standard decorators");
      }
      if (this.hasOwnProperty("getPropertyDescriptor")) {
        issueWarning("no-override-get-property-descriptor", "Overriding ReactiveElement.getPropertyDescriptor() is deprecated. " + "The override will not be called with standard decorators");
      }
    }
  }
  static finalizeStyles(styles) {
    const elementStyles = [];
    if (Array.isArray(styles)) {
      const set = new Set(styles.flat(Infinity).reverse());
      for (const s of set) {
        elementStyles.unshift(getCompatibleStyle(s));
      }
    } else if (styles !== undefined) {
      elementStyles.push(getCompatibleStyle(styles));
    }
    return elementStyles;
  }
  static __attributeNameForProperty(name, options) {
    const attribute = options.attribute;
    return attribute === false ? undefined : typeof attribute === "string" ? attribute : typeof name === "string" ? name.toLowerCase() : undefined;
  }
  constructor() {
    super();
    this.__instanceProperties = undefined;
    this.isUpdatePending = false;
    this.hasUpdated = false;
    this.__reflectingProperty = null;
    this.__initialize();
  }
  __initialize() {
    this.__updatePromise = new Promise((res) => this.enableUpdating = res);
    this._$changedProperties = new Map;
    this.__saveInstanceProperties();
    this.requestUpdate();
    this.constructor._initializers?.forEach((i) => i(this));
  }
  addController(controller) {
    (this.__controllers ??= new Set).add(controller);
    if (this.renderRoot !== undefined && this.isConnected) {
      controller.hostConnected?.();
    }
  }
  removeController(controller) {
    this.__controllers?.delete(controller);
  }
  __saveInstanceProperties() {
    const instanceProperties = new Map;
    const elementProperties = this.constructor.elementProperties;
    for (const p of elementProperties.keys()) {
      if (this.hasOwnProperty(p)) {
        instanceProperties.set(p, this[p]);
        delete this[p];
      }
    }
    if (instanceProperties.size > 0) {
      this.__instanceProperties = instanceProperties;
    }
  }
  createRenderRoot() {
    const renderRoot = this.shadowRoot ?? this.attachShadow(this.constructor.shadowRootOptions);
    adoptStyles(renderRoot, this.constructor.elementStyles);
    return renderRoot;
  }
  connectedCallback() {
    this.renderRoot ??= this.createRenderRoot();
    this.enableUpdating(true);
    this.__controllers?.forEach((c) => c.hostConnected?.());
  }
  enableUpdating(_requestedUpdate) {}
  disconnectedCallback() {
    this.__controllers?.forEach((c) => c.hostDisconnected?.());
  }
  attributeChangedCallback(name, _old, value) {
    this._$attributeToProperty(name, value);
  }
  __propertyToAttribute(name, value) {
    const elemProperties = this.constructor.elementProperties;
    const options = elemProperties.get(name);
    const attr = this.constructor.__attributeNameForProperty(name, options);
    if (attr !== undefined && options.reflect === true) {
      const converter = options.converter?.toAttribute !== undefined ? options.converter : defaultConverter;
      const attrValue = converter.toAttribute(value, options.type);
      if (DEV_MODE && this.constructor.enabledWarnings.includes("migration") && attrValue === undefined) {
        issueWarning("undefined-attribute-value", `The attribute value for the ${name} property is ` + `undefined on element ${this.localName}. The attribute will be ` + `removed, but in the previous version of \`ReactiveElement\`, ` + `the attribute would not have changed.`);
      }
      this.__reflectingProperty = name;
      if (attrValue == null) {
        this.removeAttribute(attr);
      } else {
        this.setAttribute(attr, attrValue);
      }
      this.__reflectingProperty = null;
    }
  }
  _$attributeToProperty(name, value) {
    const ctor = this.constructor;
    const propName = ctor.__attributeToPropertyMap.get(name);
    if (propName !== undefined && this.__reflectingProperty !== propName) {
      const options = ctor.getPropertyOptions(propName);
      const converter = typeof options.converter === "function" ? { fromAttribute: options.converter } : options.converter?.fromAttribute !== undefined ? options.converter : defaultConverter;
      this.__reflectingProperty = propName;
      const convertedValue = converter.fromAttribute(value, options.type);
      this[propName] = convertedValue ?? this.__defaultValues?.get(propName) ?? convertedValue;
      this.__reflectingProperty = null;
    }
  }
  requestUpdate(name, oldValue, options, useNewValue = false, newValue) {
    if (name !== undefined) {
      if (DEV_MODE && name instanceof Event) {
        issueWarning(``, `The requestUpdate() method was called with an Event as the property name. This is probably a mistake caused by binding this.requestUpdate as an event listener. Instead bind a function that will call it with no arguments: () => this.requestUpdate()`);
      }
      const ctor = this.constructor;
      if (useNewValue === false) {
        newValue = this[name];
      }
      options ??= ctor.getPropertyOptions(name);
      const changed = (options.hasChanged ?? notEqual)(newValue, oldValue) || options.useDefault && options.reflect && newValue === this.__defaultValues?.get(name) && !this.hasAttribute(ctor.__attributeNameForProperty(name, options));
      if (changed) {
        this._$changeProperty(name, oldValue, options);
      } else {
        return;
      }
    }
    if (this.isUpdatePending === false) {
      this.__updatePromise = this.__enqueueUpdate();
    }
  }
  _$changeProperty(name, oldValue, { useDefault, reflect, wrapped }, initializeValue) {
    if (useDefault && !(this.__defaultValues ??= new Map).has(name)) {
      this.__defaultValues.set(name, initializeValue ?? oldValue ?? this[name]);
      if (wrapped !== true || initializeValue !== undefined) {
        return;
      }
    }
    if (!this._$changedProperties.has(name)) {
      if (!this.hasUpdated && !useDefault) {
        oldValue = undefined;
      }
      this._$changedProperties.set(name, oldValue);
    }
    if (reflect === true && this.__reflectingProperty !== name) {
      (this.__reflectingProperties ??= new Set).add(name);
    }
  }
  async __enqueueUpdate() {
    this.isUpdatePending = true;
    try {
      await this.__updatePromise;
    } catch (e) {
      Promise.reject(e);
    }
    const result = this.scheduleUpdate();
    if (result != null) {
      await result;
    }
    return !this.isUpdatePending;
  }
  scheduleUpdate() {
    const result = this.performUpdate();
    if (DEV_MODE && this.constructor.enabledWarnings.includes("async-perform-update") && typeof result?.then === "function") {
      issueWarning("async-perform-update", `Element ${this.localName} returned a Promise from performUpdate(). ` + `This behavior is deprecated and will be removed in a future ` + `version of ReactiveElement.`);
    }
    return result;
  }
  performUpdate() {
    if (!this.isUpdatePending) {
      return;
    }
    debugLogEvent?.({ kind: "update" });
    if (!this.hasUpdated) {
      this.renderRoot ??= this.createRenderRoot();
      if (DEV_MODE) {
        const ctor = this.constructor;
        const shadowedProperties = [...ctor.elementProperties.keys()].filter((p) => this.hasOwnProperty(p) && (p in getPrototypeOf(this)));
        if (shadowedProperties.length) {
          throw new Error(`The following properties on element ${this.localName} will not ` + `trigger updates as expected because they are set using class ` + `fields: ${shadowedProperties.join(", ")}. ` + `Native class fields and some compiled output will overwrite ` + `accessors used for detecting changes. See ` + `https://lit.dev/msg/class-field-shadowing ` + `for more information.`);
        }
      }
      if (this.__instanceProperties) {
        for (const [p, value] of this.__instanceProperties) {
          this[p] = value;
        }
        this.__instanceProperties = undefined;
      }
      const elementProperties = this.constructor.elementProperties;
      if (elementProperties.size > 0) {
        for (const [p, options] of elementProperties) {
          const { wrapped } = options;
          const value = this[p];
          if (wrapped === true && !this._$changedProperties.has(p) && value !== undefined) {
            this._$changeProperty(p, undefined, options, value);
          }
        }
      }
    }
    let shouldUpdate = false;
    const changedProperties = this._$changedProperties;
    try {
      shouldUpdate = this.shouldUpdate(changedProperties);
      if (shouldUpdate) {
        this.willUpdate(changedProperties);
        this.__controllers?.forEach((c) => c.hostUpdate?.());
        this.update(changedProperties);
      } else {
        this.__markUpdated();
      }
    } catch (e) {
      shouldUpdate = false;
      this.__markUpdated();
      throw e;
    }
    if (shouldUpdate) {
      this._$didUpdate(changedProperties);
    }
  }
  willUpdate(_changedProperties) {}
  _$didUpdate(changedProperties) {
    this.__controllers?.forEach((c) => c.hostUpdated?.());
    if (!this.hasUpdated) {
      this.hasUpdated = true;
      this.firstUpdated(changedProperties);
    }
    this.updated(changedProperties);
    if (DEV_MODE && this.isUpdatePending && this.constructor.enabledWarnings.includes("change-in-update")) {
      issueWarning("change-in-update", `Element ${this.localName} scheduled an update ` + `(generally because a property was set) ` + `after an update completed, causing a new update to be scheduled. ` + `This is inefficient and should be avoided unless the next update ` + `can only be scheduled as a side effect of the previous update.`);
    }
  }
  __markUpdated() {
    this._$changedProperties = new Map;
    this.isUpdatePending = false;
  }
  get updateComplete() {
    return this.getUpdateComplete();
  }
  getUpdateComplete() {
    return this.__updatePromise;
  }
  shouldUpdate(_changedProperties) {
    return true;
  }
  update(_changedProperties) {
    this.__reflectingProperties &&= this.__reflectingProperties.forEach((p) => this.__propertyToAttribute(p, this[p]));
    this.__markUpdated();
  }
  updated(_changedProperties) {}
  firstUpdated(_changedProperties) {}
}
ReactiveElement.elementStyles = [];
ReactiveElement.shadowRootOptions = { mode: "open" };
ReactiveElement[JSCompiler_renameProperty("elementProperties", ReactiveElement)] = new Map;
ReactiveElement[JSCompiler_renameProperty("finalized", ReactiveElement)] = new Map;
polyfillSupport?.({ ReactiveElement });
if (DEV_MODE) {
  ReactiveElement.enabledWarnings = [
    "change-in-update",
    "async-perform-update"
  ];
  const ensureOwnWarnings = function(ctor) {
    if (!ctor.hasOwnProperty(JSCompiler_renameProperty("enabledWarnings", ctor))) {
      ctor.enabledWarnings = ctor.enabledWarnings.slice();
    }
  };
  ReactiveElement.enableWarning = function(warning) {
    ensureOwnWarnings(this);
    if (!this.enabledWarnings.includes(warning)) {
      this.enabledWarnings.push(warning);
    }
  };
  ReactiveElement.disableWarning = function(warning) {
    ensureOwnWarnings(this);
    const i = this.enabledWarnings.indexOf(warning);
    if (i >= 0) {
      this.enabledWarnings.splice(i, 1);
    }
  };
}
(global2.reactiveElementVersions ??= []).push("2.1.2");
if (DEV_MODE && global2.reactiveElementVersions.length > 1) {
  queueMicrotask(() => {
    issueWarning("multiple-versions", `Multiple versions of Lit loaded. Loading multiple versions ` + `is not recommended.`);
  });
}

// node_modules/lit-html/development/lit-html.js
var DEV_MODE2 = true;
var ENABLE_EXTRA_SECURITY_HOOKS = true;
var ENABLE_SHADYDOM_NOPATCH = true;
var NODE_MODE3 = false;
var global3 = globalThis;
var debugLogEvent2 = DEV_MODE2 ? (event) => {
  const shouldEmit = global3.emitLitDebugLogEvents;
  if (!shouldEmit) {
    return;
  }
  global3.dispatchEvent(new CustomEvent("lit-debug", {
    detail: event
  }));
} : undefined;
var debugLogRenderId = 0;
var issueWarning2;
if (DEV_MODE2) {
  global3.litIssuedWarnings ??= new Set;
  issueWarning2 = (code, warning) => {
    warning += code ? ` See https://lit.dev/msg/${code} for more information.` : "";
    if (!global3.litIssuedWarnings.has(warning) && !global3.litIssuedWarnings.has(code)) {
      console.warn(warning);
      global3.litIssuedWarnings.add(warning);
    }
  };
  queueMicrotask(() => {
    issueWarning2("dev-mode", `Lit is in dev mode. Not recommended for production!`);
  });
}
var wrap = ENABLE_SHADYDOM_NOPATCH && global3.ShadyDOM?.inUse && global3.ShadyDOM?.noPatch === true ? global3.ShadyDOM.wrap : (node) => node;
var trustedTypes2 = global3.trustedTypes;
var policy = trustedTypes2 ? trustedTypes2.createPolicy("lit-html", {
  createHTML: (s) => s
}) : undefined;
var identityFunction = (value) => value;
var noopSanitizer = (_node, _name, _type) => identityFunction;
var setSanitizer = (newSanitizer) => {
  if (!ENABLE_EXTRA_SECURITY_HOOKS) {
    return;
  }
  if (sanitizerFactoryInternal !== noopSanitizer) {
    throw new Error(`Attempted to overwrite existing lit-html security policy.` + ` setSanitizeDOMValueFactory should be called at most once.`);
  }
  sanitizerFactoryInternal = newSanitizer;
};
var _testOnlyClearSanitizerFactoryDoNotCallOrElse = () => {
  sanitizerFactoryInternal = noopSanitizer;
};
var createSanitizer = (node, name, type) => {
  return sanitizerFactoryInternal(node, name, type);
};
var boundAttributeSuffix = "$lit$";
var marker = `lit$${Math.random().toFixed(9).slice(2)}$`;
var markerMatch = "?" + marker;
var nodeMarker = `<${markerMatch}>`;
var d = NODE_MODE3 && global3.document === undefined ? {
  createTreeWalker() {
    return {};
  }
} : document;
var createMarker = () => d.createComment("");
var isPrimitive = (value) => value === null || typeof value != "object" && typeof value != "function";
var isArray = Array.isArray;
var isIterable = (value) => isArray(value) || typeof value?.[Symbol.iterator] === "function";
var SPACE_CHAR = `[ 	
\f\r]`;
var ATTR_VALUE_CHAR = `[^ 	
\f\r"'\`<>=]`;
var NAME_CHAR = `[^\\s"'>=/]`;
var textEndRegex = /<(?:(!--|\/[^a-zA-Z])|(\/?[a-zA-Z][^>\s]*)|(\/?$))/g;
var COMMENT_START = 1;
var TAG_NAME = 2;
var DYNAMIC_TAG_NAME = 3;
var commentEndRegex = /-->/g;
var comment2EndRegex = />/g;
var tagEndRegex = new RegExp(`>|${SPACE_CHAR}(?:(${NAME_CHAR}+)(${SPACE_CHAR}*=${SPACE_CHAR}*(?:${ATTR_VALUE_CHAR}|("|')|))|$)`, "g");
var ENTIRE_MATCH = 0;
var ATTRIBUTE_NAME = 1;
var SPACES_AND_EQUALS = 2;
var QUOTE_CHAR = 3;
var singleQuoteAttrEndRegex = /'/g;
var doubleQuoteAttrEndRegex = /"/g;
var rawTextElement = /^(?:script|style|textarea|title)$/i;
var HTML_RESULT = 1;
var SVG_RESULT = 2;
var MATHML_RESULT = 3;
var ATTRIBUTE_PART = 1;
var CHILD_PART = 2;
var PROPERTY_PART = 3;
var BOOLEAN_ATTRIBUTE_PART = 4;
var EVENT_PART = 5;
var ELEMENT_PART = 6;
var COMMENT_PART = 7;
var tag = (type) => (strings, ...values) => {
  if (DEV_MODE2 && strings.some((s) => s === undefined)) {
    console.warn(`Some template strings are undefined.
` + "This is probably caused by illegal octal escape sequences.");
  }
  if (DEV_MODE2) {
    if (values.some((val) => val?.["_$litStatic$"])) {
      issueWarning2("", `Static values 'literal' or 'unsafeStatic' cannot be used as values to non-static templates.
` + `Please use the static 'html' tag function. See https://lit.dev/docs/templates/expressions/#static-expressions`);
    }
  }
  return {
    ["_$litType$"]: type,
    strings,
    values
  };
};
var html = tag(HTML_RESULT);
var svg = tag(SVG_RESULT);
var mathml = tag(MATHML_RESULT);
var noChange = Symbol.for("lit-noChange");
var nothing = Symbol.for("lit-nothing");
var templateCache = new WeakMap;
var walker = d.createTreeWalker(d, 129);
var sanitizerFactoryInternal = noopSanitizer;
function trustFromTemplateString(tsa, stringFromTSA) {
  if (!isArray(tsa) || !tsa.hasOwnProperty("raw")) {
    let message = "invalid template strings array";
    if (DEV_MODE2) {
      message = `
          Internal Error: expected template strings to be an array
          with a 'raw' field. Faking a template strings array by
          calling html or svg like an ordinary function is effectively
          the same as calling unsafeHtml and can lead to major security
          issues, e.g. opening your code up to XSS attacks.
          If you're using the html or svg tagged template functions normally
          and still seeing this error, please file a bug at
          https://github.com/lit/lit/issues/new?template=bug_report.md
          and include information about your build tooling, if any.
        `.trim().replace(/\n */g, `
`);
    }
    throw new Error(message);
  }
  return policy !== undefined ? policy.createHTML(stringFromTSA) : stringFromTSA;
}
var getTemplateHtml = (strings, type) => {
  const l = strings.length - 1;
  const attrNames = [];
  let html2 = type === SVG_RESULT ? "<svg>" : type === MATHML_RESULT ? "<math>" : "";
  let rawTextEndRegex;
  let regex = textEndRegex;
  for (let i = 0;i < l; i++) {
    const s = strings[i];
    let attrNameEndIndex = -1;
    let attrName;
    let lastIndex = 0;
    let match;
    while (lastIndex < s.length) {
      regex.lastIndex = lastIndex;
      match = regex.exec(s);
      if (match === null) {
        break;
      }
      lastIndex = regex.lastIndex;
      if (regex === textEndRegex) {
        if (match[COMMENT_START] === "!--") {
          regex = commentEndRegex;
        } else if (match[COMMENT_START] !== undefined) {
          regex = comment2EndRegex;
        } else if (match[TAG_NAME] !== undefined) {
          if (rawTextElement.test(match[TAG_NAME])) {
            rawTextEndRegex = new RegExp(`</${match[TAG_NAME]}`, "g");
          }
          regex = tagEndRegex;
        } else if (match[DYNAMIC_TAG_NAME] !== undefined) {
          if (DEV_MODE2) {
            throw new Error("Bindings in tag names are not supported. Please use static templates instead. " + "See https://lit.dev/docs/templates/expressions/#static-expressions");
          }
          regex = tagEndRegex;
        }
      } else if (regex === tagEndRegex) {
        if (match[ENTIRE_MATCH] === ">") {
          regex = rawTextEndRegex ?? textEndRegex;
          attrNameEndIndex = -1;
        } else if (match[ATTRIBUTE_NAME] === undefined) {
          attrNameEndIndex = -2;
        } else {
          attrNameEndIndex = regex.lastIndex - match[SPACES_AND_EQUALS].length;
          attrName = match[ATTRIBUTE_NAME];
          regex = match[QUOTE_CHAR] === undefined ? tagEndRegex : match[QUOTE_CHAR] === '"' ? doubleQuoteAttrEndRegex : singleQuoteAttrEndRegex;
        }
      } else if (regex === doubleQuoteAttrEndRegex || regex === singleQuoteAttrEndRegex) {
        regex = tagEndRegex;
      } else if (regex === commentEndRegex || regex === comment2EndRegex) {
        regex = textEndRegex;
      } else {
        regex = tagEndRegex;
        rawTextEndRegex = undefined;
      }
    }
    if (DEV_MODE2) {
      console.assert(attrNameEndIndex === -1 || regex === tagEndRegex || regex === singleQuoteAttrEndRegex || regex === doubleQuoteAttrEndRegex, "unexpected parse state B");
    }
    const end = regex === tagEndRegex && strings[i + 1].startsWith("/>") ? " " : "";
    html2 += regex === textEndRegex ? s + nodeMarker : attrNameEndIndex >= 0 ? (attrNames.push(attrName), s.slice(0, attrNameEndIndex) + boundAttributeSuffix + s.slice(attrNameEndIndex)) + marker + end : s + marker + (attrNameEndIndex === -2 ? i : end);
  }
  const htmlResult = html2 + (strings[l] || "<?>") + (type === SVG_RESULT ? "</svg>" : type === MATHML_RESULT ? "</math>" : "");
  return [trustFromTemplateString(strings, htmlResult), attrNames];
};

class Template {
  constructor({ strings, ["_$litType$"]: type }, options) {
    this.parts = [];
    let node;
    let nodeIndex = 0;
    let attrNameIndex = 0;
    const partCount = strings.length - 1;
    const parts = this.parts;
    const [html2, attrNames] = getTemplateHtml(strings, type);
    this.el = Template.createElement(html2, options);
    walker.currentNode = this.el.content;
    if (type === SVG_RESULT || type === MATHML_RESULT) {
      const wrapper = this.el.content.firstChild;
      wrapper.replaceWith(...wrapper.childNodes);
    }
    while ((node = walker.nextNode()) !== null && parts.length < partCount) {
      if (node.nodeType === 1) {
        if (DEV_MODE2) {
          const tag2 = node.localName;
          if (/^(?:textarea|template)$/i.test(tag2) && node.innerHTML.includes(marker)) {
            const m = `Expressions are not supported inside \`${tag2}\` ` + `elements. See https://lit.dev/msg/expression-in-${tag2} for more ` + `information.`;
            if (tag2 === "template") {
              throw new Error(m);
            } else
              issueWarning2("", m);
          }
        }
        if (node.hasAttributes()) {
          for (const name of node.getAttributeNames()) {
            if (name.endsWith(boundAttributeSuffix)) {
              const realName = attrNames[attrNameIndex++];
              const value = node.getAttribute(name);
              const statics = value.split(marker);
              const m = /([.?@])?(.*)/.exec(realName);
              parts.push({
                type: ATTRIBUTE_PART,
                index: nodeIndex,
                name: m[2],
                strings: statics,
                ctor: m[1] === "." ? PropertyPart : m[1] === "?" ? BooleanAttributePart : m[1] === "@" ? EventPart : AttributePart
              });
              node.removeAttribute(name);
            } else if (name.startsWith(marker)) {
              parts.push({
                type: ELEMENT_PART,
                index: nodeIndex
              });
              node.removeAttribute(name);
            }
          }
        }
        if (rawTextElement.test(node.tagName)) {
          const strings2 = node.textContent.split(marker);
          const lastIndex = strings2.length - 1;
          if (lastIndex > 0) {
            node.textContent = trustedTypes2 ? trustedTypes2.emptyScript : "";
            for (let i = 0;i < lastIndex; i++) {
              node.append(strings2[i], createMarker());
              walker.nextNode();
              parts.push({ type: CHILD_PART, index: ++nodeIndex });
            }
            node.append(strings2[lastIndex], createMarker());
          }
        }
      } else if (node.nodeType === 8) {
        const data = node.data;
        if (data === markerMatch) {
          parts.push({ type: CHILD_PART, index: nodeIndex });
        } else {
          let i = -1;
          while ((i = node.data.indexOf(marker, i + 1)) !== -1) {
            parts.push({ type: COMMENT_PART, index: nodeIndex });
            i += marker.length - 1;
          }
        }
      }
      nodeIndex++;
    }
    if (DEV_MODE2) {
      if (attrNames.length !== attrNameIndex) {
        throw new Error(`Detected duplicate attribute bindings. This occurs if your template ` + `has duplicate attributes on an element tag. For example ` + `"<input ?disabled=\${true} ?disabled=\${false}>" contains a ` + `duplicate "disabled" attribute. The error was detected in ` + `the following template: 
` + "`" + strings.join("${...}") + "`");
      }
    }
    debugLogEvent2 && debugLogEvent2({
      kind: "template prep",
      template: this,
      clonableTemplate: this.el,
      parts: this.parts,
      strings
    });
  }
  static createElement(html2, _options) {
    const el = d.createElement("template");
    el.innerHTML = html2;
    return el;
  }
}
function resolveDirective(part, value, parent = part, attributeIndex) {
  if (value === noChange) {
    return value;
  }
  let currentDirective = attributeIndex !== undefined ? parent.__directives?.[attributeIndex] : parent.__directive;
  const nextDirectiveConstructor = isPrimitive(value) ? undefined : value["_$litDirective$"];
  if (currentDirective?.constructor !== nextDirectiveConstructor) {
    currentDirective?.["_$notifyDirectiveConnectionChanged"]?.(false);
    if (nextDirectiveConstructor === undefined) {
      currentDirective = undefined;
    } else {
      currentDirective = new nextDirectiveConstructor(part);
      currentDirective._$initialize(part, parent, attributeIndex);
    }
    if (attributeIndex !== undefined) {
      (parent.__directives ??= [])[attributeIndex] = currentDirective;
    } else {
      parent.__directive = currentDirective;
    }
  }
  if (currentDirective !== undefined) {
    value = resolveDirective(part, currentDirective._$resolve(part, value.values), currentDirective, attributeIndex);
  }
  return value;
}

class TemplateInstance {
  constructor(template, parent) {
    this._$parts = [];
    this._$disconnectableChildren = undefined;
    this._$template = template;
    this._$parent = parent;
  }
  get parentNode() {
    return this._$parent.parentNode;
  }
  get _$isConnected() {
    return this._$parent._$isConnected;
  }
  _clone(options) {
    const { el: { content }, parts } = this._$template;
    const fragment = (options?.creationScope ?? d).importNode(content, true);
    walker.currentNode = fragment;
    let node = walker.nextNode();
    let nodeIndex = 0;
    let partIndex = 0;
    let templatePart = parts[0];
    while (templatePart !== undefined) {
      if (nodeIndex === templatePart.index) {
        let part;
        if (templatePart.type === CHILD_PART) {
          part = new ChildPart(node, node.nextSibling, this, options);
        } else if (templatePart.type === ATTRIBUTE_PART) {
          part = new templatePart.ctor(node, templatePart.name, templatePart.strings, this, options);
        } else if (templatePart.type === ELEMENT_PART) {
          part = new ElementPart(node, this, options);
        }
        this._$parts.push(part);
        templatePart = parts[++partIndex];
      }
      if (nodeIndex !== templatePart?.index) {
        node = walker.nextNode();
        nodeIndex++;
      }
    }
    walker.currentNode = d;
    return fragment;
  }
  _update(values) {
    let i = 0;
    for (const part of this._$parts) {
      if (part !== undefined) {
        debugLogEvent2 && debugLogEvent2({
          kind: "set part",
          part,
          value: values[i],
          valueIndex: i,
          values,
          templateInstance: this
        });
        if (part.strings !== undefined) {
          part._$setValue(values, part, i);
          i += part.strings.length - 2;
        } else {
          part._$setValue(values[i]);
        }
      }
      i++;
    }
  }
}

class ChildPart {
  get _$isConnected() {
    return this._$parent?._$isConnected ?? this.__isConnected;
  }
  constructor(startNode, endNode, parent, options) {
    this.type = CHILD_PART;
    this._$committedValue = nothing;
    this._$disconnectableChildren = undefined;
    this._$startNode = startNode;
    this._$endNode = endNode;
    this._$parent = parent;
    this.options = options;
    this.__isConnected = options?.isConnected ?? true;
    if (ENABLE_EXTRA_SECURITY_HOOKS) {
      this._textSanitizer = undefined;
    }
  }
  get parentNode() {
    let parentNode = wrap(this._$startNode).parentNode;
    const parent = this._$parent;
    if (parent !== undefined && parentNode?.nodeType === 11) {
      parentNode = parent.parentNode;
    }
    return parentNode;
  }
  get startNode() {
    return this._$startNode;
  }
  get endNode() {
    return this._$endNode;
  }
  _$setValue(value, directiveParent = this) {
    if (DEV_MODE2 && this.parentNode === null) {
      throw new Error(`This \`ChildPart\` has no \`parentNode\` and therefore cannot accept a value. This likely means the element containing the part was manipulated in an unsupported way outside of Lit's control such that the part's marker nodes were ejected from DOM. For example, setting the element's \`innerHTML\` or \`textContent\` can do this.`);
    }
    value = resolveDirective(this, value, directiveParent);
    if (isPrimitive(value)) {
      if (value === nothing || value == null || value === "") {
        if (this._$committedValue !== nothing) {
          debugLogEvent2 && debugLogEvent2({
            kind: "commit nothing to child",
            start: this._$startNode,
            end: this._$endNode,
            parent: this._$parent,
            options: this.options
          });
          this._$clear();
        }
        this._$committedValue = nothing;
      } else if (value !== this._$committedValue && value !== noChange) {
        this._commitText(value);
      }
    } else if (value["_$litType$"] !== undefined) {
      this._commitTemplateResult(value);
    } else if (value.nodeType !== undefined) {
      if (DEV_MODE2 && this.options?.host === value) {
        this._commitText(`[probable mistake: rendered a template's host in itself ` + `(commonly caused by writing \${this} in a template]`);
        console.warn(`Attempted to render the template host`, value, `inside itself. This is almost always a mistake, and in dev mode `, `we render some warning text. In production however, we'll `, `render it, which will usually result in an error, and sometimes `, `in the element disappearing from the DOM.`);
        return;
      }
      this._commitNode(value);
    } else if (isIterable(value)) {
      this._commitIterable(value);
    } else {
      this._commitText(value);
    }
  }
  _insert(node) {
    return wrap(wrap(this._$startNode).parentNode).insertBefore(node, this._$endNode);
  }
  _commitNode(value) {
    if (this._$committedValue !== value) {
      this._$clear();
      if (ENABLE_EXTRA_SECURITY_HOOKS && sanitizerFactoryInternal !== noopSanitizer) {
        const parentNodeName = this._$startNode.parentNode?.nodeName;
        if (parentNodeName === "STYLE" || parentNodeName === "SCRIPT") {
          let message = "Forbidden";
          if (DEV_MODE2) {
            if (parentNodeName === "STYLE") {
              message = `Lit does not support binding inside style nodes. ` + `This is a security risk, as style injection attacks can ` + `exfiltrate data and spoof UIs. ` + `Consider instead using css\`...\` literals ` + `to compose styles, and do dynamic styling with ` + `css custom properties, ::parts, <slot>s, ` + `and by mutating the DOM rather than stylesheets.`;
            } else {
              message = `Lit does not support binding inside script nodes. ` + `This is a security risk, as it could allow arbitrary ` + `code execution.`;
            }
          }
          throw new Error(message);
        }
      }
      debugLogEvent2 && debugLogEvent2({
        kind: "commit node",
        start: this._$startNode,
        parent: this._$parent,
        value,
        options: this.options
      });
      this._$committedValue = this._insert(value);
    }
  }
  _commitText(value) {
    if (this._$committedValue !== nothing && isPrimitive(this._$committedValue)) {
      const node = wrap(this._$startNode).nextSibling;
      if (ENABLE_EXTRA_SECURITY_HOOKS) {
        if (this._textSanitizer === undefined) {
          this._textSanitizer = createSanitizer(node, "data", "property");
        }
        value = this._textSanitizer(value);
      }
      debugLogEvent2 && debugLogEvent2({
        kind: "commit text",
        node,
        value,
        options: this.options
      });
      node.data = value;
    } else {
      if (ENABLE_EXTRA_SECURITY_HOOKS) {
        const textNode = d.createTextNode("");
        this._commitNode(textNode);
        if (this._textSanitizer === undefined) {
          this._textSanitizer = createSanitizer(textNode, "data", "property");
        }
        value = this._textSanitizer(value);
        debugLogEvent2 && debugLogEvent2({
          kind: "commit text",
          node: textNode,
          value,
          options: this.options
        });
        textNode.data = value;
      } else {
        this._commitNode(d.createTextNode(value));
        debugLogEvent2 && debugLogEvent2({
          kind: "commit text",
          node: wrap(this._$startNode).nextSibling,
          value,
          options: this.options
        });
      }
    }
    this._$committedValue = value;
  }
  _commitTemplateResult(result) {
    const { values, ["_$litType$"]: type } = result;
    const template = typeof type === "number" ? this._$getTemplate(result) : (type.el === undefined && (type.el = Template.createElement(trustFromTemplateString(type.h, type.h[0]), this.options)), type);
    if (this._$committedValue?._$template === template) {
      debugLogEvent2 && debugLogEvent2({
        kind: "template updating",
        template,
        instance: this._$committedValue,
        parts: this._$committedValue._$parts,
        options: this.options,
        values
      });
      this._$committedValue._update(values);
    } else {
      const instance = new TemplateInstance(template, this);
      const fragment = instance._clone(this.options);
      debugLogEvent2 && debugLogEvent2({
        kind: "template instantiated",
        template,
        instance,
        parts: instance._$parts,
        options: this.options,
        fragment,
        values
      });
      instance._update(values);
      debugLogEvent2 && debugLogEvent2({
        kind: "template instantiated and updated",
        template,
        instance,
        parts: instance._$parts,
        options: this.options,
        fragment,
        values
      });
      this._commitNode(fragment);
      this._$committedValue = instance;
    }
  }
  _$getTemplate(result) {
    let template = templateCache.get(result.strings);
    if (template === undefined) {
      templateCache.set(result.strings, template = new Template(result));
    }
    return template;
  }
  _commitIterable(value) {
    if (!isArray(this._$committedValue)) {
      this._$committedValue = [];
      this._$clear();
    }
    const itemParts = this._$committedValue;
    let partIndex = 0;
    let itemPart;
    for (const item of value) {
      if (partIndex === itemParts.length) {
        itemParts.push(itemPart = new ChildPart(this._insert(createMarker()), this._insert(createMarker()), this, this.options));
      } else {
        itemPart = itemParts[partIndex];
      }
      itemPart._$setValue(item);
      partIndex++;
    }
    if (partIndex < itemParts.length) {
      this._$clear(itemPart && wrap(itemPart._$endNode).nextSibling, partIndex);
      itemParts.length = partIndex;
    }
  }
  _$clear(start = wrap(this._$startNode).nextSibling, from) {
    this._$notifyConnectionChanged?.(false, true, from);
    while (start !== this._$endNode) {
      const n = wrap(start).nextSibling;
      wrap(start).remove();
      start = n;
    }
  }
  setConnected(isConnected) {
    if (this._$parent === undefined) {
      this.__isConnected = isConnected;
      this._$notifyConnectionChanged?.(isConnected);
    } else if (DEV_MODE2) {
      throw new Error("part.setConnected() may only be called on a " + "RootPart returned from render().");
    }
  }
}

class AttributePart {
  get tagName() {
    return this.element.tagName;
  }
  get _$isConnected() {
    return this._$parent._$isConnected;
  }
  constructor(element, name, strings, parent, options) {
    this.type = ATTRIBUTE_PART;
    this._$committedValue = nothing;
    this._$disconnectableChildren = undefined;
    this.element = element;
    this.name = name;
    this._$parent = parent;
    this.options = options;
    if (strings.length > 2 || strings[0] !== "" || strings[1] !== "") {
      this._$committedValue = new Array(strings.length - 1).fill(new String);
      this.strings = strings;
    } else {
      this._$committedValue = nothing;
    }
    if (ENABLE_EXTRA_SECURITY_HOOKS) {
      this._sanitizer = undefined;
    }
  }
  _$setValue(value, directiveParent = this, valueIndex, noCommit) {
    const strings = this.strings;
    let change = false;
    if (strings === undefined) {
      value = resolveDirective(this, value, directiveParent, 0);
      change = !isPrimitive(value) || value !== this._$committedValue && value !== noChange;
      if (change) {
        this._$committedValue = value;
      }
    } else {
      const values = value;
      value = strings[0];
      let i, v;
      for (i = 0;i < strings.length - 1; i++) {
        v = resolveDirective(this, values[valueIndex + i], directiveParent, i);
        if (v === noChange) {
          v = this._$committedValue[i];
        }
        change ||= !isPrimitive(v) || v !== this._$committedValue[i];
        if (v === nothing) {
          value = nothing;
        } else if (value !== nothing) {
          value += (v ?? "") + strings[i + 1];
        }
        this._$committedValue[i] = v;
      }
    }
    if (change && !noCommit) {
      this._commitValue(value);
    }
  }
  _commitValue(value) {
    if (value === nothing) {
      wrap(this.element).removeAttribute(this.name);
    } else {
      if (ENABLE_EXTRA_SECURITY_HOOKS) {
        if (this._sanitizer === undefined) {
          this._sanitizer = sanitizerFactoryInternal(this.element, this.name, "attribute");
        }
        value = this._sanitizer(value ?? "");
      }
      debugLogEvent2 && debugLogEvent2({
        kind: "commit attribute",
        element: this.element,
        name: this.name,
        value,
        options: this.options
      });
      wrap(this.element).setAttribute(this.name, value ?? "");
    }
  }
}

class PropertyPart extends AttributePart {
  constructor() {
    super(...arguments);
    this.type = PROPERTY_PART;
  }
  _commitValue(value) {
    if (ENABLE_EXTRA_SECURITY_HOOKS) {
      if (this._sanitizer === undefined) {
        this._sanitizer = sanitizerFactoryInternal(this.element, this.name, "property");
      }
      value = this._sanitizer(value);
    }
    debugLogEvent2 && debugLogEvent2({
      kind: "commit property",
      element: this.element,
      name: this.name,
      value,
      options: this.options
    });
    this.element[this.name] = value === nothing ? undefined : value;
  }
}

class BooleanAttributePart extends AttributePart {
  constructor() {
    super(...arguments);
    this.type = BOOLEAN_ATTRIBUTE_PART;
  }
  _commitValue(value) {
    debugLogEvent2 && debugLogEvent2({
      kind: "commit boolean attribute",
      element: this.element,
      name: this.name,
      value: !!(value && value !== nothing),
      options: this.options
    });
    wrap(this.element).toggleAttribute(this.name, !!value && value !== nothing);
  }
}

class EventPart extends AttributePart {
  constructor(element, name, strings, parent, options) {
    super(element, name, strings, parent, options);
    this.type = EVENT_PART;
    if (DEV_MODE2 && this.strings !== undefined) {
      throw new Error(`A \`<${element.localName}>\` has a \`@${name}=...\` listener with ` + "invalid content. Event listeners in templates must have exactly " + "one expression and no surrounding text.");
    }
  }
  _$setValue(newListener, directiveParent = this) {
    newListener = resolveDirective(this, newListener, directiveParent, 0) ?? nothing;
    if (newListener === noChange) {
      return;
    }
    const oldListener = this._$committedValue;
    const shouldRemoveListener = newListener === nothing && oldListener !== nothing || newListener.capture !== oldListener.capture || newListener.once !== oldListener.once || newListener.passive !== oldListener.passive;
    const shouldAddListener = newListener !== nothing && (oldListener === nothing || shouldRemoveListener);
    debugLogEvent2 && debugLogEvent2({
      kind: "commit event listener",
      element: this.element,
      name: this.name,
      value: newListener,
      options: this.options,
      removeListener: shouldRemoveListener,
      addListener: shouldAddListener,
      oldListener
    });
    if (shouldRemoveListener) {
      this.element.removeEventListener(this.name, this, oldListener);
    }
    if (shouldAddListener) {
      this.element.addEventListener(this.name, this, newListener);
    }
    this._$committedValue = newListener;
  }
  handleEvent(event) {
    if (typeof this._$committedValue === "function") {
      this._$committedValue.call(this.options?.host ?? this.element, event);
    } else {
      this._$committedValue.handleEvent(event);
    }
  }
}

class ElementPart {
  constructor(element, parent, options) {
    this.element = element;
    this.type = ELEMENT_PART;
    this._$disconnectableChildren = undefined;
    this._$parent = parent;
    this.options = options;
  }
  get _$isConnected() {
    return this._$parent._$isConnected;
  }
  _$setValue(value) {
    debugLogEvent2 && debugLogEvent2({
      kind: "commit to element binding",
      element: this.element,
      value,
      options: this.options
    });
    resolveDirective(this, value);
  }
}
var polyfillSupport2 = DEV_MODE2 ? global3.litHtmlPolyfillSupportDevMode : global3.litHtmlPolyfillSupport;
polyfillSupport2?.(Template, ChildPart);
(global3.litHtmlVersions ??= []).push("3.3.2");
if (DEV_MODE2 && global3.litHtmlVersions.length > 1) {
  queueMicrotask(() => {
    issueWarning2("multiple-versions", `Multiple versions of Lit loaded. ` + `Loading multiple versions is not recommended.`);
  });
}
var render = (value, container, options) => {
  if (DEV_MODE2 && container == null) {
    throw new TypeError(`The container to render into may not be ${container}`);
  }
  const renderId = DEV_MODE2 ? debugLogRenderId++ : 0;
  const partOwnerNode = options?.renderBefore ?? container;
  let part = partOwnerNode["_$litPart$"];
  debugLogEvent2 && debugLogEvent2({
    kind: "begin render",
    id: renderId,
    value,
    container,
    options,
    part
  });
  if (part === undefined) {
    const endNode = options?.renderBefore ?? null;
    partOwnerNode["_$litPart$"] = part = new ChildPart(container.insertBefore(createMarker(), endNode), endNode, undefined, options ?? {});
  }
  part._$setValue(value);
  debugLogEvent2 && debugLogEvent2({
    kind: "end render",
    id: renderId,
    value,
    container,
    options,
    part
  });
  return part;
};
if (ENABLE_EXTRA_SECURITY_HOOKS) {
  render.setSanitizer = setSanitizer;
  render.createSanitizer = createSanitizer;
  if (DEV_MODE2) {
    render._testOnlyClearSanitizerFactoryDoNotCallOrElse = _testOnlyClearSanitizerFactoryDoNotCallOrElse;
  }
}

// node_modules/lit-element/development/lit-element.js
var JSCompiler_renameProperty2 = (prop, _obj) => prop;
var DEV_MODE3 = true;
var global4 = globalThis;
var issueWarning3;
if (DEV_MODE3) {
  global4.litIssuedWarnings ??= new Set;
  issueWarning3 = (code, warning) => {
    warning += ` See https://lit.dev/msg/${code} for more information.`;
    if (!global4.litIssuedWarnings.has(warning) && !global4.litIssuedWarnings.has(code)) {
      console.warn(warning);
      global4.litIssuedWarnings.add(warning);
    }
  };
}

class LitElement extends ReactiveElement {
  constructor() {
    super(...arguments);
    this.renderOptions = { host: this };
    this.__childPart = undefined;
  }
  createRenderRoot() {
    const renderRoot = super.createRenderRoot();
    this.renderOptions.renderBefore ??= renderRoot.firstChild;
    return renderRoot;
  }
  update(changedProperties) {
    const value = this.render();
    if (!this.hasUpdated) {
      this.renderOptions.isConnected = this.isConnected;
    }
    super.update(changedProperties);
    this.__childPart = render(value, this.renderRoot, this.renderOptions);
  }
  connectedCallback() {
    super.connectedCallback();
    this.__childPart?.setConnected(true);
  }
  disconnectedCallback() {
    super.disconnectedCallback();
    this.__childPart?.setConnected(false);
  }
  render() {
    return noChange;
  }
}
LitElement["_$litElement$"] = true;
LitElement[JSCompiler_renameProperty2("finalized", LitElement)] = true;
global4.litElementHydrateSupport?.({ LitElement });
var polyfillSupport3 = DEV_MODE3 ? global4.litElementPolyfillSupportDevMode : global4.litElementPolyfillSupport;
polyfillSupport3?.({ LitElement });
(global4.litElementVersions ??= []).push("4.2.2");
if (DEV_MODE3 && global4.litElementVersions.length > 1) {
  queueMicrotask(() => {
    issueWarning3("multiple-versions", `Multiple versions of Lit loaded. Loading multiple versions ` + `is not recommended.`);
  });
}
// node_modules/@vaadin/component-base/src/define.js
window.Vaadin ||= {};
window.Vaadin.featureFlags ||= {};
function dashToCamelCase(dash) {
  return dash.replace(/-[a-z]/gu, (m) => m[1].toUpperCase());
}
var experimentalMap = {};
function defineCustomElement(CustomElement, version = "25.0.4") {
  Object.defineProperty(CustomElement, "version", {
    get() {
      return version;
    }
  });
  if (CustomElement.experimental) {
    const featureFlagKey = typeof CustomElement.experimental === "string" ? CustomElement.experimental : `${dashToCamelCase(CustomElement.is.split("-").slice(1).join("-"))}Component`;
    if (!window.Vaadin.featureFlags[featureFlagKey] && !experimentalMap[featureFlagKey]) {
      experimentalMap[featureFlagKey] = new Set;
      experimentalMap[featureFlagKey].add(CustomElement);
      Object.defineProperty(window.Vaadin.featureFlags, featureFlagKey, {
        get() {
          return experimentalMap[featureFlagKey].size === 0;
        },
        set(value) {
          if (!!value && experimentalMap[featureFlagKey].size > 0) {
            experimentalMap[featureFlagKey].forEach((elementClass) => {
              customElements.define(elementClass.is, elementClass);
            });
            experimentalMap[featureFlagKey].clear();
          }
        }
      });
      return;
    } else if (experimentalMap[featureFlagKey]) {
      experimentalMap[featureFlagKey].add(CustomElement);
      return;
    }
  }
  const defined = customElements.get(CustomElement.is);
  if (!defined) {
    customElements.define(CustomElement.is, CustomElement);
  } else {
    const definedVersion = defined.version;
    if (definedVersion && CustomElement.version && definedVersion === CustomElement.version) {
      console.warn(`The component ${CustomElement.is} has been loaded twice`);
    } else {
      console.error(`Tried to define ${CustomElement.is} version ${CustomElement.version} when version ${defined.version} is already in use. Something will probably break.`);
    }
  }
}

// node_modules/@open-wc/dedupe-mixin/src/dedupeMixin.js
var appliedClassMixins = new WeakMap;
function wasMixinPreviouslyApplied(mixin, superClass) {
  let klass = superClass;
  while (klass) {
    if (appliedClassMixins.get(klass) === mixin) {
      return true;
    }
    klass = Object.getPrototypeOf(klass);
  }
  return false;
}
function dedupeMixin(mixin) {
  return (superClass) => {
    if (wasMixinPreviouslyApplied(mixin, superClass)) {
      return superClass;
    }
    const mixedClass = mixin(superClass);
    appliedClassMixins.set(mixedClass, mixin);
    return mixedClass;
  };
}
// node_modules/@vaadin/component-base/src/path-utils.js
function get(path, object) {
  return path.split(".").reduce((obj, property) => obj ? obj[property] : undefined, object);
}
function set(path, value, object) {
  const pathParts = path.split(".");
  const lastPart = pathParts.pop();
  const target = pathParts.reduce((target2, part) => target2[part], object);
  target[lastPart] = value;
}

// node_modules/@vaadin/component-base/src/polylit-mixin.js
var caseMap = {};
var CAMEL_TO_DASH = /([A-Z])/gu;
function camelToDash(camel) {
  if (!caseMap[camel]) {
    caseMap[camel] = camel.replace(CAMEL_TO_DASH, "-$1").toLowerCase();
  }
  return caseMap[camel];
}
function upper(name) {
  return name[0].toUpperCase() + name.substring(1);
}
function parseObserver(observerString) {
  const [method, rest] = observerString.split("(");
  const observerProps = rest.replace(")", "").split(",").map((prop) => prop.trim());
  return {
    method,
    observerProps
  };
}
function getOrCreateMap(obj, name) {
  if (!Object.prototype.hasOwnProperty.call(obj, name)) {
    obj[name] = new Map(obj[name]);
  }
  return obj[name];
}
var PolylitMixinImplementation = (superclass) => {

  class PolylitMixinClass extends superclass {
    static enabledWarnings = [];
    static createProperty(name, options) {
      if ([String, Boolean, Number, Array].includes(options)) {
        options = {
          type: options
        };
      }
      if (options && options.reflectToAttribute) {
        options.reflect = true;
      }
      super.createProperty(name, options);
    }
    static getOrCreateMap(name) {
      return getOrCreateMap(this, name);
    }
    static finalize() {
      if (window.litIssuedWarnings) {
        window.litIssuedWarnings.add("no-override-create-property");
        window.litIssuedWarnings.add("no-override-get-property-descriptor");
      }
      super.finalize();
      if (Array.isArray(this.observers)) {
        const complexObservers = this.getOrCreateMap("__complexObservers");
        this.observers.forEach((observer) => {
          const { method, observerProps } = parseObserver(observer);
          complexObservers.set(method, observerProps);
        });
      }
    }
    static addCheckedInitializer(initializer) {
      super.addInitializer((instance) => {
        if (instance instanceof this) {
          initializer(instance);
        }
      });
    }
    static getPropertyDescriptor(name, key, options) {
      const defaultDescriptor = super.getPropertyDescriptor(name, key, options);
      let result = defaultDescriptor;
      this.getOrCreateMap("__propKeys").set(name, key);
      if (options.sync) {
        result = {
          get: defaultDescriptor.get,
          set(value) {
            const oldValue = this[name];
            if (notEqual(value, oldValue)) {
              this[key] = value;
              this.requestUpdate(name, oldValue, options);
              if (this.hasUpdated) {
                this.performUpdate();
              }
            }
          },
          configurable: true,
          enumerable: true
        };
      }
      if (options.readOnly) {
        const setter = result.set;
        this.addCheckedInitializer((instance) => {
          instance[`_set${upper(name)}`] = function(value) {
            setter.call(instance, value);
          };
        });
        result = {
          get: result.get,
          set() {},
          configurable: true,
          enumerable: true
        };
      }
      if ("value" in options) {
        this.addCheckedInitializer((instance) => {
          const value = typeof options.value === "function" ? options.value.call(instance) : options.value;
          if (options.readOnly) {
            instance[`_set${upper(name)}`](value);
          } else {
            instance[name] = value;
          }
        });
      }
      if (options.observer) {
        const method = options.observer;
        this.getOrCreateMap("__observers").set(name, method);
        this.addCheckedInitializer((instance) => {
          if (!instance[method]) {
            console.warn(`observer method ${method} not defined`);
          }
        });
      }
      if (options.notify) {
        if (!this.__notifyProps) {
          this.__notifyProps = new Set;
        } else if (!this.hasOwnProperty("__notifyProps")) {
          const notifyProps = this.__notifyProps;
          this.__notifyProps = new Set(notifyProps);
        }
        this.__notifyProps.add(name);
      }
      if (options.computed) {
        const assignComputedMethod = `__assignComputed${name}`;
        const observer = parseObserver(options.computed);
        this.prototype[assignComputedMethod] = function(...props) {
          this[name] = this[observer.method](...props);
        };
        this.getOrCreateMap("__computedObservers").set(assignComputedMethod, observer.observerProps);
      }
      if (!options.attribute) {
        options.attribute = camelToDash(name);
      }
      return result;
    }
    static get polylitConfig() {
      return {
        asyncFirstRender: false
      };
    }
    connectedCallback() {
      super.connectedCallback();
      const { polylitConfig } = this.constructor;
      if (!this.hasUpdated && !polylitConfig.asyncFirstRender) {
        this.performUpdate();
      }
    }
    firstUpdated() {
      super.firstUpdated();
      if (!this.$) {
        this.$ = {};
      }
      this.renderRoot.querySelectorAll("[id]").forEach((node) => {
        this.$[node.id] = node;
      });
    }
    ready() {}
    willUpdate(props) {
      if (this.constructor.__computedObservers) {
        this.__runComplexObservers(props, this.constructor.__computedObservers);
      }
    }
    updated(props) {
      const wasReadyInvoked = this.__isReadyInvoked;
      this.__isReadyInvoked = true;
      if (this.constructor.__observers) {
        this.__runObservers(props, this.constructor.__observers);
      }
      if (this.constructor.__complexObservers) {
        this.__runComplexObservers(props, this.constructor.__complexObservers);
      }
      if (this.__dynamicPropertyObservers) {
        this.__runDynamicObservers(props, this.__dynamicPropertyObservers);
      }
      if (this.__dynamicMethodObservers) {
        this.__runComplexObservers(props, this.__dynamicMethodObservers);
      }
      if (this.constructor.__notifyProps) {
        this.__runNotifyProps(props, this.constructor.__notifyProps);
      }
      if (!wasReadyInvoked) {
        this.ready();
      }
    }
    setProperties(props) {
      Object.entries(props).forEach(([name, value]) => {
        const key = this.constructor.__propKeys.get(name);
        const oldValue = this[key];
        this[key] = value;
        this.requestUpdate(name, oldValue);
      });
      if (this.hasUpdated) {
        this.performUpdate();
      }
    }
    _createMethodObserver(observer) {
      const dynamicObservers = getOrCreateMap(this, "__dynamicMethodObservers");
      const { method, observerProps } = parseObserver(observer);
      dynamicObservers.set(method, observerProps);
    }
    _createPropertyObserver(property, method) {
      const dynamicObservers = getOrCreateMap(this, "__dynamicPropertyObservers");
      dynamicObservers.set(method, property);
    }
    __runComplexObservers(props, observers) {
      observers.forEach((observerProps, method) => {
        if (observerProps.some((prop) => props.has(prop))) {
          if (!this[method]) {
            console.warn(`observer method ${method} not defined`);
          } else {
            this[method](...observerProps.map((prop) => this[prop]));
          }
        }
      });
    }
    __runDynamicObservers(props, observers) {
      observers.forEach((prop, method) => {
        if (props.has(prop) && this[method]) {
          this[method](this[prop], props.get(prop));
        }
      });
    }
    __runObservers(props, observers) {
      props.forEach((v, k) => {
        const observer = observers.get(k);
        if (observer !== undefined && this[observer]) {
          this[observer](this[k], v);
        }
      });
    }
    __runNotifyProps(props, notifyProps) {
      props.forEach((_, k) => {
        if (notifyProps.has(k)) {
          this.dispatchEvent(new CustomEvent(`${camelToDash(k)}-changed`, {
            detail: {
              value: this[k]
            }
          }));
        }
      });
    }
    _get(path, object) {
      return get(path, object);
    }
    _set(path, value, object) {
      set(path, value, object);
    }
  }
  return PolylitMixinClass;
};
var PolylitMixin = dedupeMixin(PolylitMixinImplementation);

// node_modules/@vaadin/component-base/src/async.js
var microtaskCurrHandle = 0;
var microtaskLastHandle = 0;
var microtaskCallbacks = [];
var microtaskScheduled = false;
function microtaskFlush() {
  microtaskScheduled = false;
  const len = microtaskCallbacks.length;
  for (let i = 0;i < len; i++) {
    const cb = microtaskCallbacks[i];
    if (cb) {
      try {
        cb();
      } catch (e) {
        setTimeout(() => {
          throw e;
        });
      }
    }
  }
  microtaskCallbacks.splice(0, len);
  microtaskLastHandle += len;
}
var timeOut = {
  after(delay) {
    return {
      run(fn) {
        return window.setTimeout(fn, delay);
      },
      cancel(handle) {
        window.clearTimeout(handle);
      }
    };
  },
  run(fn, delay) {
    return window.setTimeout(fn, delay);
  },
  cancel(handle) {
    window.clearTimeout(handle);
  }
};
var animationFrame = {
  run(fn) {
    return window.requestAnimationFrame(fn);
  },
  cancel(handle) {
    window.cancelAnimationFrame(handle);
  }
};
var idlePeriod = {
  run(fn) {
    return window.requestIdleCallback ? window.requestIdleCallback(fn) : window.setTimeout(fn, 16);
  },
  cancel(handle) {
    if (window.cancelIdleCallback) {
      window.cancelIdleCallback(handle);
    } else {
      window.clearTimeout(handle);
    }
  }
};
var microTask = {
  run(callback) {
    if (!microtaskScheduled) {
      microtaskScheduled = true;
      queueMicrotask(() => microtaskFlush());
    }
    microtaskCallbacks.push(callback);
    const result = microtaskCurrHandle;
    microtaskCurrHandle += 1;
    return result;
  },
  cancel(handle) {
    const idx = handle - microtaskLastHandle;
    if (idx >= 0) {
      if (!microtaskCallbacks[idx]) {
        throw new Error(`invalid async handle: ${handle}`);
      }
      microtaskCallbacks[idx] = null;
    }
  }
};

// node_modules/@vaadin/component-base/src/debounce.js
var debouncerQueue = new Set;

class Debouncer {
  static debounce(debouncer, asyncModule, callback) {
    if (debouncer instanceof Debouncer) {
      debouncer._cancelAsync();
    } else {
      debouncer = new Debouncer;
    }
    debouncer.setConfig(asyncModule, callback);
    return debouncer;
  }
  constructor() {
    this._asyncModule = null;
    this._callback = null;
    this._timer = null;
  }
  setConfig(asyncModule, callback) {
    this._asyncModule = asyncModule;
    this._callback = callback;
    this._timer = this._asyncModule.run(() => {
      this._timer = null;
      debouncerQueue.delete(this);
      this._callback();
    });
  }
  cancel() {
    if (this.isActive()) {
      this._cancelAsync();
      debouncerQueue.delete(this);
    }
  }
  _cancelAsync() {
    if (this.isActive()) {
      this._asyncModule.cancel(this._timer);
      this._timer = null;
    }
  }
  flush() {
    if (this.isActive()) {
      this.cancel();
      this._callback();
    }
  }
  isActive() {
    return this._timer != null;
  }
}
function enqueueDebouncer(debouncer) {
  debouncerQueue.add(debouncer);
}
function flushDebouncers() {
  const didFlush = Boolean(debouncerQueue.size);
  debouncerQueue.forEach((debouncer) => {
    try {
      debouncer.flush();
    } catch (e) {
      setTimeout(() => {
        throw e;
      });
    }
  });
  return didFlush;
}
var flush = () => {
  let debouncers;
  do {
    debouncers = flushDebouncers();
  } while (debouncers);
};

// node_modules/@vaadin/component-base/src/dir-mixin.js
var directionSubscribers = [];
function alignDirs(element, documentDir, elementDir = element.getAttribute("dir")) {
  if (documentDir) {
    element.setAttribute("dir", documentDir);
  } else if (elementDir != null) {
    element.removeAttribute("dir");
  }
}
function getDocumentDir() {
  return document.documentElement.getAttribute("dir");
}
function directionUpdater() {
  const documentDir = getDocumentDir();
  directionSubscribers.forEach((element) => {
    alignDirs(element, documentDir);
  });
}
var directionObserver = new MutationObserver(directionUpdater);
directionObserver.observe(document.documentElement, { attributes: true, attributeFilter: ["dir"] });
var DirMixin = (superClass) => class VaadinDirMixin extends superClass {
  static get properties() {
    return {
      dir: {
        type: String,
        value: "",
        reflectToAttribute: true,
        converter: {
          fromAttribute: (attr) => {
            return !attr ? "" : attr;
          },
          toAttribute: (prop) => {
            return prop === "" ? null : prop;
          }
        }
      }
    };
  }
  get __isRTL() {
    return this.getAttribute("dir") === "rtl";
  }
  connectedCallback() {
    super.connectedCallback();
    if (!this.hasAttribute("dir") || this.__restoreSubscription) {
      this.__subscribe();
      alignDirs(this, getDocumentDir(), null);
    }
  }
  attributeChangedCallback(name, oldValue, newValue) {
    super.attributeChangedCallback(name, oldValue, newValue);
    if (name !== "dir") {
      return;
    }
    const documentDir = getDocumentDir();
    const newValueEqlDocDir = newValue === documentDir && directionSubscribers.indexOf(this) === -1;
    const newValueEmptied = !newValue && oldValue && directionSubscribers.indexOf(this) === -1;
    const newDiffValue = newValue !== documentDir && oldValue === documentDir;
    if (newValueEqlDocDir || newValueEmptied) {
      this.__subscribe();
      alignDirs(this, documentDir, newValue);
    } else if (newDiffValue) {
      this.__unsubscribe();
    }
  }
  disconnectedCallback() {
    super.disconnectedCallback();
    this.__restoreSubscription = directionSubscribers.includes(this);
    this.__unsubscribe();
  }
  _valueToNodeAttribute(node, value, attribute) {
    if (attribute === "dir" && value === "" && !node.hasAttribute("dir")) {
      return;
    }
    super._valueToNodeAttribute(node, value, attribute);
  }
  _attributeToProperty(attribute, value, type) {
    if (attribute === "dir" && !value) {
      this.dir = "";
    } else {
      super._attributeToProperty(attribute, value, type);
    }
  }
  __subscribe() {
    if (!directionSubscribers.includes(this)) {
      directionSubscribers.push(this);
    }
  }
  __unsubscribe() {
    if (directionSubscribers.includes(this)) {
      directionSubscribers.splice(directionSubscribers.indexOf(this), 1);
    }
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-helpers.js
function getBodyRowCells(row) {
  return row.__cells || Array.from(row.querySelectorAll('[part~="cell"]:not([part~="details-cell"])'));
}
function iterateChildren(container, callback) {
  [...container.children].forEach(callback);
}
function iterateRowCells(row, callback) {
  getBodyRowCells(row).forEach(callback);
  if (row.__detailsCell) {
    callback(row.__detailsCell);
  }
}
function updateColumnOrders(columns, scope, baseOrder) {
  let c = 1;
  columns.forEach((column) => {
    if (c % 10 === 0) {
      c += 1;
    }
    column._order = baseOrder + c * scope;
    c += 1;
  });
}
function updateState(element, attribute, value) {
  switch (typeof value) {
    case "boolean":
      element.toggleAttribute(attribute, value);
      break;
    case "string":
      element.setAttribute(attribute, value);
      break;
    default:
      element.removeAttribute(attribute);
      break;
  }
}
function updatePart(element, part, value) {
  element.classList.toggle(part, value || value === "");
  element.part.toggle(part, value || value === "");
  element.part.length === 0 && element.removeAttribute("part");
}
function updateCellsPart(cells, part, value) {
  cells.forEach((cell) => {
    updatePart(cell, part, value);
  });
}
function updateBooleanRowStates(row, states) {
  const cells = getBodyRowCells(row);
  Object.entries(states).forEach(([state, value]) => {
    updateState(row, state, value);
    const rowPart = `${state}-row`;
    updatePart(row, rowPart, value);
    updateCellsPart(cells, `${rowPart}-cell`, value);
  });
}
function updateStringRowStates(row, states) {
  const cells = getBodyRowCells(row);
  Object.entries(states).forEach(([state, value]) => {
    const prevValue = row.getAttribute(state);
    updateState(row, state, value);
    if (prevValue) {
      const prevRowPart = `${state}-${prevValue}-row`;
      updatePart(row, prevRowPart, false);
      updateCellsPart(cells, `${prevRowPart}-cell`, false);
    }
    if (value) {
      const rowPart = `${state}-${value}-row`;
      updatePart(row, rowPart, value);
      updateCellsPart(cells, `${rowPart}-cell`, value);
    }
  });
}
function updateCellState(cell, attribute, value, part, oldPart) {
  updateState(cell, attribute, value);
  if (oldPart) {
    updatePart(cell, oldPart, false);
  }
  updatePart(cell, part || `${attribute}-cell`, value);
}
function findTreeToggleCell(row) {
  return getBodyRowCells(row).find((cell) => cell._content.querySelector("vaadin-grid-tree-toggle"));
}

class ColumnObserver {
  constructor(host, callback) {
    this.__host = host;
    this.__callback = callback;
    this.__currentSlots = [];
    this.__onMutation = this.__onMutation.bind(this);
    this.__observer = new MutationObserver(this.__onMutation);
    this.__observer.observe(host, {
      childList: true
    });
    this.__initialCallDebouncer = Debouncer.debounce(this.__initialCallDebouncer, microTask, () => this.__onMutation());
  }
  disconnect() {
    this.__observer.disconnect();
    this.__initialCallDebouncer.cancel();
    this.__toggleSlotChangeListeners(false);
  }
  flush() {
    this.__onMutation();
  }
  __toggleSlotChangeListeners(add) {
    this.__currentSlots.forEach((slot) => {
      if (add) {
        slot.addEventListener("slotchange", this.__onMutation);
      } else {
        slot.removeEventListener("slotchange", this.__onMutation);
      }
    });
  }
  __onMutation() {
    const initialCall = !this.__currentColumns;
    this.__currentColumns = this.__currentColumns || [];
    const columns = ColumnObserver.getColumns(this.__host);
    const addedColumns = columns.filter((column) => !this.__currentColumns.includes(column));
    const removedColumns = this.__currentColumns.filter((column) => !columns.includes(column));
    const orderChanged = this.__currentColumns.some((column, index) => column !== columns[index]);
    this.__currentColumns = columns;
    this.__toggleSlotChangeListeners(false);
    this.__currentSlots = [...this.__host.children].filter((child) => child instanceof HTMLSlotElement);
    this.__toggleSlotChangeListeners(true);
    const invokeCallback = initialCall || addedColumns.length || removedColumns.length || orderChanged;
    if (invokeCallback) {
      this.__callback(addedColumns, removedColumns);
    }
  }
  static __isColumnElement(node) {
    return node.nodeType === Node.ELEMENT_NODE && /\bcolumn\b/u.test(node.localName);
  }
  static getColumns(host) {
    const columns = [];
    const isColumnElement = host._isColumnElement || ColumnObserver.__isColumnElement;
    [...host.children].forEach((child) => {
      if (isColumnElement(child)) {
        columns.push(child);
      } else if (child instanceof HTMLSlotElement) {
        [...child.assignedElements({ flatten: true })].filter((assignedElement) => isColumnElement(assignedElement)).forEach((assignedElement) => columns.push(assignedElement));
      }
    });
    return columns;
  }
}

// node_modules/@vaadin/grid/src/vaadin-grid-column-mixin.js
var ColumnBaseMixin = (superClass) => class ColumnBaseMixin2 extends superClass {
  static get properties() {
    return {
      resizable: {
        type: Boolean,
        sync: true,
        value() {
          if (this.localName === "vaadin-grid-column-group") {
            return;
          }
          const parent = this.parentNode;
          if (parent && parent.localName === "vaadin-grid-column-group") {
            return parent.resizable || false;
          }
          return false;
        }
      },
      frozen: {
        type: Boolean,
        value: false,
        sync: true
      },
      frozenToEnd: {
        type: Boolean,
        value: false,
        sync: true
      },
      rowHeader: {
        type: Boolean,
        value: false,
        sync: true
      },
      hidden: {
        type: Boolean,
        value: false,
        sync: true
      },
      header: {
        type: String,
        sync: true
      },
      textAlign: {
        type: String,
        sync: true
      },
      headerPartName: {
        type: String,
        sync: true
      },
      footerPartName: {
        type: String,
        sync: true
      },
      _lastFrozen: {
        type: Boolean,
        value: false,
        sync: true
      },
      _bodyContentHidden: {
        type: Boolean,
        value: false,
        sync: true
      },
      _firstFrozenToEnd: {
        type: Boolean,
        value: false,
        sync: true
      },
      _order: {
        type: Number,
        sync: true
      },
      _reorderStatus: {
        type: Boolean,
        sync: true
      },
      _emptyCells: Array,
      _headerCell: {
        type: Object,
        sync: true
      },
      _footerCell: {
        type: Object,
        sync: true
      },
      _grid: Object,
      __initialized: {
        type: Boolean,
        value: true
      },
      headerRenderer: {
        type: Function,
        sync: true
      },
      _headerRenderer: {
        type: Function,
        computed: "_computeHeaderRenderer(headerRenderer, header, __initialized)"
      },
      footerRenderer: {
        type: Function,
        sync: true
      },
      _footerRenderer: {
        type: Function,
        computed: "_computeFooterRenderer(footerRenderer, __initialized)"
      },
      __gridColumnElement: {
        type: Boolean,
        value: true
      }
    };
  }
  static get observers() {
    return [
      "_widthChanged(width, _headerCell, _footerCell, _cells)",
      "_frozenChanged(frozen, _headerCell, _footerCell, _cells)",
      "_frozenToEndChanged(frozenToEnd, _headerCell, _footerCell, _cells)",
      "_flexGrowChanged(flexGrow, _headerCell, _footerCell, _cells)",
      "_textAlignChanged(textAlign, _cells, _headerCell, _footerCell)",
      "_orderChanged(_order, _headerCell, _footerCell, _cells)",
      "_lastFrozenChanged(_lastFrozen)",
      "_firstFrozenToEndChanged(_firstFrozenToEnd)",
      "_onRendererOrBindingChanged(_renderer, _cells, _bodyContentHidden, path)",
      "_onHeaderRendererOrBindingChanged(_headerRenderer, _headerCell, path, header)",
      "_onFooterRendererOrBindingChanged(_footerRenderer, _footerCell)",
      "_resizableChanged(resizable, _headerCell)",
      "_reorderStatusChanged(_reorderStatus, _headerCell, _footerCell, _cells)",
      "_hiddenChanged(hidden, _headerCell, _footerCell, _cells)",
      "_rowHeaderChanged(rowHeader, _cells)",
      "__headerFooterPartNameChanged(_headerCell, _footerCell, headerPartName, footerPartName)"
    ];
  }
  get _grid() {
    if (!this._gridValue) {
      this._gridValue = this._findHostGrid();
    }
    return this._gridValue;
  }
  get _allCells() {
    return [].concat(this._cells || []).concat(this._emptyCells || []).concat(this._headerCell).concat(this._footerCell).filter((cell) => cell);
  }
  connectedCallback() {
    super.connectedCallback();
    requestAnimationFrame(() => {
      if (!this._grid) {
        return;
      }
      this._allCells.forEach((cell) => {
        if (!cell._content.parentNode) {
          this._grid.appendChild(cell._content);
        }
      });
    });
  }
  disconnectedCallback() {
    super.disconnectedCallback();
    requestAnimationFrame(() => {
      if (this._grid) {
        return;
      }
      this._allCells.forEach((cell) => {
        if (cell._content.parentNode) {
          cell._content.parentNode.removeChild(cell._content);
        }
      });
    });
    this._gridValue = undefined;
  }
  _findHostGrid() {
    let el = this;
    while (el && !/^vaadin.*grid(-pro)?$/u.test(el.localName)) {
      el = el.assignedSlot ? el.assignedSlot.parentNode : el.parentNode;
    }
    return el || undefined;
  }
  _renderHeaderAndFooter() {
    this._renderHeaderCellContent(this._headerRenderer, this._headerCell);
    this._renderFooterCellContent(this._footerRenderer, this._footerCell);
  }
  _flexGrowChanged(flexGrow) {
    if (this.parentElement && this.parentElement._columnPropChanged) {
      this.parentElement._columnPropChanged("flexGrow");
    }
    this._allCells.forEach((cell) => {
      cell.style.flexGrow = flexGrow;
    });
  }
  _orderChanged(order) {
    this._allCells.forEach((cell) => {
      cell.style.order = order;
    });
  }
  _widthChanged(width) {
    if (this.parentElement && this.parentElement._columnPropChanged) {
      this.parentElement._columnPropChanged("width");
    }
    this._allCells.forEach((cell) => {
      cell.style.width = width;
    });
  }
  _frozenChanged(frozen) {
    if (this.parentElement && this.parentElement._columnPropChanged) {
      this.parentElement._columnPropChanged("frozen", frozen);
    }
    this._allCells.forEach((cell) => {
      updateCellState(cell, "frozen", frozen);
    });
    if (this._grid && this._grid._frozenCellsChanged) {
      this._grid._frozenCellsChanged();
    }
  }
  _frozenToEndChanged(frozenToEnd) {
    if (this.parentElement && this.parentElement._columnPropChanged) {
      this.parentElement._columnPropChanged("frozenToEnd", frozenToEnd);
    }
    this._allCells.forEach((cell) => {
      if (this._grid && cell.parentElement === this._grid.$.sizer) {
        return;
      }
      updateCellState(cell, "frozen-to-end", frozenToEnd);
    });
    if (this._grid && this._grid._frozenCellsChanged) {
      this._grid._frozenCellsChanged();
    }
  }
  _lastFrozenChanged(lastFrozen) {
    this._allCells.forEach((cell) => {
      updateCellState(cell, "last-frozen", lastFrozen);
    });
    if (this.parentElement && this.parentElement._columnPropChanged) {
      this.parentElement._lastFrozen = lastFrozen;
    }
  }
  _firstFrozenToEndChanged(firstFrozenToEnd) {
    this._allCells.forEach((cell) => {
      if (this._grid && cell.parentElement === this._grid.$.sizer) {
        return;
      }
      updateCellState(cell, "first-frozen-to-end", firstFrozenToEnd);
    });
    if (this.parentElement && this.parentElement._columnPropChanged) {
      this.parentElement._firstFrozenToEnd = firstFrozenToEnd;
    }
  }
  _rowHeaderChanged(rowHeader, cells) {
    if (!cells) {
      return;
    }
    cells.forEach((cell) => {
      cell.setAttribute("role", rowHeader ? "rowheader" : "gridcell");
    });
  }
  _generateHeader(path) {
    return path.substr(path.lastIndexOf(".") + 1).replace(/([A-Z])/gu, "-$1").toLowerCase().replace(/-/gu, " ").replace(/^./u, (match) => match.toUpperCase());
  }
  _reorderStatusChanged(reorderStatus) {
    const prevStatus = this.__previousReorderStatus;
    const oldPart = prevStatus ? `reorder-${prevStatus}-cell` : "";
    const newPart = `reorder-${reorderStatus}-cell`;
    this._allCells.forEach((cell) => {
      updateCellState(cell, "reorder-status", reorderStatus, newPart, oldPart);
    });
    this.__previousReorderStatus = reorderStatus;
  }
  _resizableChanged(resizable, headerCell) {
    if (resizable === undefined || headerCell === undefined) {
      return;
    }
    if (headerCell) {
      [headerCell].concat(this._emptyCells).forEach((cell) => {
        if (cell) {
          const existingHandle = cell.querySelector('[part~="resize-handle"]');
          if (existingHandle) {
            cell.removeChild(existingHandle);
          }
          if (resizable) {
            const handle = document.createElement("div");
            updatePart(handle, "resize-handle", true);
            cell.appendChild(handle);
          }
        }
      });
    }
  }
  _textAlignChanged(textAlign) {
    if (textAlign === undefined || this._grid === undefined) {
      return;
    }
    if (["start", "end", "center"].indexOf(textAlign) === -1) {
      console.warn('textAlign can only be set as "start", "end" or "center"');
      return;
    }
    this._allCells.forEach((cell) => {
      cell._content.style.textAlign = textAlign;
    });
  }
  _hiddenChanged(hidden) {
    if (this.parentElement && this.parentElement._columnPropChanged) {
      this.parentElement._columnPropChanged("hidden", hidden);
    }
    if (!!hidden !== !!this._previousHidden && this._grid) {
      if (hidden === true) {
        this._allCells.forEach((cell) => {
          if (cell._content.parentNode) {
            cell._content.parentNode.removeChild(cell._content);
          }
        });
      }
      this._grid._debouncerHiddenChanged = Debouncer.debounce(this._grid._debouncerHiddenChanged, animationFrame, () => {
        if (this._grid && this._grid._renderColumnTree) {
          this._grid._renderColumnTree(this._grid._columnTree);
        }
      });
      if (this._grid._debounceUpdateFrozenColumn) {
        this._grid._debounceUpdateFrozenColumn();
      }
      if (this._grid._resetKeyboardNavigation) {
        this._grid._resetKeyboardNavigation();
      }
    }
    this._previousHidden = hidden;
  }
  _runRenderer(renderer, cell, model) {
    const isVisibleBodyCell = model && model.item && !cell.parentElement.hidden;
    const shouldRender = isVisibleBodyCell || renderer === this._headerRenderer || renderer === this._footerRenderer;
    if (!shouldRender) {
      return;
    }
    const args = [cell._content, this];
    if (isVisibleBodyCell) {
      args.push(model);
    }
    renderer.apply(this, args);
  }
  __renderCellsContent(renderer, cells) {
    if (this.hidden || !this._grid) {
      return;
    }
    cells.forEach((cell) => {
      if (!cell.parentElement) {
        return;
      }
      const model = this._grid.__getRowModel(cell.parentElement);
      if (!renderer) {
        return;
      }
      if (cell._renderer !== renderer) {
        this._clearCellContent(cell);
      }
      cell._renderer = renderer;
      this._runRenderer(renderer, cell, model);
    });
  }
  _clearCellContent(cell) {
    cell._content.innerHTML = "";
    delete cell._content._$litPart$;
  }
  _renderHeaderCellContent(headerRenderer, headerCell) {
    if (!headerCell || !headerRenderer) {
      return;
    }
    this.__renderCellsContent(headerRenderer, [headerCell]);
    if (this._grid && headerCell.parentElement) {
      this._grid.__debounceUpdateHeaderFooterRowVisibility(headerCell.parentElement);
    }
  }
  _onHeaderRendererOrBindingChanged(headerRenderer, headerCell, ..._bindings) {
    this._renderHeaderCellContent(headerRenderer, headerCell);
  }
  __headerFooterPartNameChanged(headerCell, footerCell, headerPartName, footerPartName) {
    [
      { cell: headerCell, partName: headerPartName },
      { cell: footerCell, partName: footerPartName }
    ].forEach(({ cell, partName }) => {
      if (cell) {
        const customParts = cell.__customParts || [];
        cell.part.remove(...customParts);
        cell.__customParts = partName ? partName.trim().split(" ") : [];
        cell.part.add(...cell.__customParts);
      }
    });
  }
  _renderBodyCellsContent(renderer, cells) {
    if (!cells || !renderer) {
      return;
    }
    this.__renderCellsContent(renderer, cells);
  }
  _onRendererOrBindingChanged(renderer, cells, ..._bindings) {
    this._renderBodyCellsContent(renderer, cells);
  }
  _renderFooterCellContent(footerRenderer, footerCell) {
    if (!footerCell || !footerRenderer) {
      return;
    }
    this.__renderCellsContent(footerRenderer, [footerCell]);
    if (this._grid && footerCell.parentElement) {
      this._grid.__debounceUpdateHeaderFooterRowVisibility(footerCell.parentElement);
    }
  }
  _onFooterRendererOrBindingChanged(footerRenderer, footerCell) {
    this._renderFooterCellContent(footerRenderer, footerCell);
  }
  __setTextContent(node, textContent) {
    if (node.textContent !== textContent) {
      node.textContent = textContent;
    }
  }
  __textHeaderRenderer() {
    this.__setTextContent(this._headerCell._content, this.header);
  }
  _defaultHeaderRenderer() {
    if (!this.path) {
      return;
    }
    this.__setTextContent(this._headerCell._content, this._generateHeader(this.path));
  }
  _defaultRenderer(root, _owner, { item }) {
    if (!this.path) {
      return;
    }
    this.__setTextContent(root, get(this.path, item));
  }
  _defaultFooterRenderer() {}
  _computeHeaderRenderer(headerRenderer, header) {
    if (headerRenderer) {
      return headerRenderer;
    }
    if (header !== undefined && header !== null) {
      return this.__textHeaderRenderer;
    }
    return this._defaultHeaderRenderer;
  }
  _computeRenderer(renderer) {
    if (renderer) {
      return renderer;
    }
    return this._defaultRenderer;
  }
  _computeFooterRenderer(footerRenderer) {
    if (footerRenderer) {
      return footerRenderer;
    }
    return this._defaultFooterRenderer;
  }
};
var GridColumnMixin = (superClass) => class extends ColumnBaseMixin(DirMixin(superClass)) {
  static get properties() {
    return {
      width: {
        type: String,
        value: "100px",
        sync: true
      },
      flexGrow: {
        type: Number,
        value: 1,
        sync: true
      },
      renderer: {
        type: Function,
        sync: true
      },
      _renderer: {
        type: Function,
        computed: "_computeRenderer(renderer, __initialized)"
      },
      path: {
        type: String,
        sync: true
      },
      autoWidth: {
        type: Boolean,
        value: false
      },
      _focusButtonMode: {
        type: Boolean,
        value: false
      },
      _cells: {
        type: Array,
        sync: true
      }
    };
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-column.js
class GridColumn extends GridColumnMixin(PolylitMixin(LitElement)) {
  static get is() {
    return "vaadin-grid-column";
  }
}
defineCustomElement(GridColumn);

// node_modules/lit-html/development/directives/if-defined.js
var ifDefined = (value) => value ?? nothing;
// node_modules/@vaadin/vaadin-development-mode-detector/vaadin-development-mode-detector.js
var DEV_MODE_CODE_REGEXP = /\/\*[\*!]\s+vaadin-dev-mode:start([\s\S]*)vaadin-dev-mode:end\s+\*\*\//i;
var FlowClients = window.Vaadin && window.Vaadin.Flow && window.Vaadin.Flow.clients;
function isMinified() {
  function test() {
    return true;
  }
  return uncommentAndRun(test);
}
function isDevelopmentMode() {
  try {
    if (isForcedDevelopmentMode()) {
      return true;
    }
    if (!isLocalhost()) {
      return false;
    }
    if (FlowClients) {
      return !isFlowProductionMode();
    }
    return !isMinified();
  } catch (e) {
    return false;
  }
}
function isForcedDevelopmentMode() {
  return localStorage.getItem("vaadin.developmentmode.force");
}
function isLocalhost() {
  return ["localhost", "127.0.0.1"].indexOf(window.location.hostname) >= 0;
}
function isFlowProductionMode() {
  if (FlowClients) {
    const productionModeApps = Object.keys(FlowClients).map((key) => FlowClients[key]).filter((client) => client.productionMode);
    if (productionModeApps.length > 0) {
      return true;
    }
  }
  return false;
}
function uncommentAndRun(callback, args) {
  if (typeof callback !== "function") {
    return;
  }
  const match = DEV_MODE_CODE_REGEXP.exec(callback.toString());
  if (match) {
    try {
      callback = new Function(match[1]);
    } catch (e) {
      console.log("vaadin-development-mode-detector: uncommentAndRun() failed", e);
    }
  }
  return callback(args);
}
window["Vaadin"] = window["Vaadin"] || {};
var runIfDevelopmentMode = function(callback, args) {
  if (window.Vaadin.developmentMode) {
    return uncommentAndRun(callback, args);
  }
};
if (window.Vaadin.developmentMode === undefined) {
  window.Vaadin.developmentMode = isDevelopmentMode();
}

// node_modules/@vaadin/vaadin-usage-statistics/vaadin-usage-statistics-collect.js
function maybeGatherAndSendStats() {
  /*! vaadin-dev-mode:start
    (function () {
  'use strict';
  
  var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) {
    return typeof obj;
  } : function (obj) {
    return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj;
  };
  
  var classCallCheck = function (instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  };
  
  var createClass = function () {
    function defineProperties(target, props) {
      for (var i = 0; i < props.length; i++) {
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor) descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
      }
    }
  
    return function (Constructor, protoProps, staticProps) {
      if (protoProps) defineProperties(Constructor.prototype, protoProps);
      if (staticProps) defineProperties(Constructor, staticProps);
      return Constructor;
    };
  }();
  
  var getPolymerVersion = function getPolymerVersion() {
    return window.Polymer && window.Polymer.version;
  };
  
  var StatisticsGatherer = function () {
    function StatisticsGatherer(logger) {
      classCallCheck(this, StatisticsGatherer);
  
      this.now = new Date().getTime();
      this.logger = logger;
    }
  
    createClass(StatisticsGatherer, [{
      key: 'frameworkVersionDetectors',
      value: function frameworkVersionDetectors() {
        return {
          'Flow': function Flow() {
            if (window.Vaadin && window.Vaadin.Flow && window.Vaadin.Flow.clients) {
              var flowVersions = Object.keys(window.Vaadin.Flow.clients).map(function (key) {
                return window.Vaadin.Flow.clients[key];
              }).filter(function (client) {
                return client.getVersionInfo;
              }).map(function (client) {
                return client.getVersionInfo().flow;
              });
              if (flowVersions.length > 0) {
                return flowVersions[0];
              }
            }
          },
          'Vaadin Framework': function VaadinFramework() {
            if (window.vaadin && window.vaadin.clients) {
              var frameworkVersions = Object.values(window.vaadin.clients).filter(function (client) {
                return client.getVersionInfo;
              }).map(function (client) {
                return client.getVersionInfo().vaadinVersion;
              });
              if (frameworkVersions.length > 0) {
                return frameworkVersions[0];
              }
            }
          },
          'AngularJs': function AngularJs() {
            if (window.angular && window.angular.version && window.angular.version) {
              return window.angular.version.full;
            }
          },
          'Angular': function Angular() {
            if (window.ng) {
              var tags = document.querySelectorAll("[ng-version]");
              if (tags.length > 0) {
                return tags[0].getAttribute("ng-version");
              }
              return "Unknown";
            }
          },
          'Backbone.js': function BackboneJs() {
            if (window.Backbone) {
              return window.Backbone.VERSION;
            }
          },
          'React': function React() {
            var reactSelector = '[data-reactroot], [data-reactid]';
            if (!!document.querySelector(reactSelector)) {
              // React does not publish the version by default
              return "unknown";
            }
          },
          'Ember': function Ember() {
            if (window.Em && window.Em.VERSION) {
              return window.Em.VERSION;
            } else if (window.Ember && window.Ember.VERSION) {
              return window.Ember.VERSION;
            }
          },
          'jQuery': function (_jQuery) {
            function jQuery() {
              return _jQuery.apply(this, arguments);
            }
  
            jQuery.toString = function () {
              return _jQuery.toString();
            };
  
            return jQuery;
          }(function () {
            if (typeof jQuery === 'function' && jQuery.prototype.jquery !== undefined) {
              return jQuery.prototype.jquery;
            }
          }),
          'Polymer': function Polymer() {
            var version = getPolymerVersion();
            if (version) {
              return version;
            }
          },
          'LitElement': function LitElement() {
            var version = window.litElementVersions && window.litElementVersions[0];
            if (version) {
              return version;
            }
          },
          'LitHtml': function LitHtml() {
            var version = window.litHtmlVersions && window.litHtmlVersions[0];
            if (version) {
              return version;
            }
          },
          'Vue.js': function VueJs() {
            if (window.Vue) {
              return window.Vue.version;
            }
          }
        };
      }
    }, {
      key: 'getUsedVaadinElements',
      value: function getUsedVaadinElements(elements) {
        var version = getPolymerVersion();
        var elementClasses = void 0;
        // NOTE: In case you edit the code here, YOU MUST UPDATE any statistics reporting code in Flow.
        // Check all locations calling the method getEntries() in
        // https://github.com/vaadin/flow/blob/master/flow-server/src/main/java/com/vaadin/flow/internal/UsageStatistics.java#L106
        // Currently it is only used by BootstrapHandler.
        if (version && version.indexOf('2') === 0) {
          // Polymer 2: components classes are stored in window.Vaadin
          elementClasses = Object.keys(window.Vaadin).map(function (c) {
            return window.Vaadin[c];
          }).filter(function (c) {
            return c.is;
          });
        } else {
          // Polymer 3: components classes are stored in window.Vaadin.registrations
          elementClasses = window.Vaadin.registrations || [];
        }
        elementClasses.forEach(function (klass) {
          var version = klass.version ? klass.version : "0.0.0";
          elements[klass.is] = { version: version };
        });
      }
    }, {
      key: 'getUsedVaadinThemes',
      value: function getUsedVaadinThemes(themes) {
        ['Lumo', 'Material'].forEach(function (themeName) {
          var theme;
          var version = getPolymerVersion();
          if (version && version.indexOf('2') === 0) {
            // Polymer 2: themes are stored in window.Vaadin
            theme = window.Vaadin[themeName];
          } else {
            // Polymer 3: themes are stored in custom element registry
            theme = customElements.get('vaadin-' + themeName.toLowerCase() + '-styles');
          }
          if (theme && theme.version) {
            themes[themeName] = { version: theme.version };
          }
        });
      }
    }, {
      key: 'getFrameworks',
      value: function getFrameworks(frameworks) {
        var detectors = this.frameworkVersionDetectors();
        Object.keys(detectors).forEach(function (framework) {
          var detector = detectors[framework];
          try {
            var version = detector();
            if (version) {
              frameworks[framework] = { version: version };
            }
          } catch (e) {}
        });
      }
    }, {
      key: 'gather',
      value: function gather(storage) {
        var storedStats = storage.read();
        var gatheredStats = {};
        var types = ["elements", "frameworks", "themes"];
  
        types.forEach(function (type) {
          gatheredStats[type] = {};
          if (!storedStats[type]) {
            storedStats[type] = {};
          }
        });
  
        var previousStats = JSON.stringify(storedStats);
  
        this.getUsedVaadinElements(gatheredStats.elements);
        this.getFrameworks(gatheredStats.frameworks);
        this.getUsedVaadinThemes(gatheredStats.themes);
  
        var now = this.now;
        types.forEach(function (type) {
          var keys = Object.keys(gatheredStats[type]);
          keys.forEach(function (key) {
            if (!storedStats[type][key] || _typeof(storedStats[type][key]) != _typeof({})) {
              storedStats[type][key] = { firstUsed: now };
            }
            // Discards any previously logged version number
            storedStats[type][key].version = gatheredStats[type][key].version;
            storedStats[type][key].lastUsed = now;
          });
        });
  
        var newStats = JSON.stringify(storedStats);
        storage.write(newStats);
        if (newStats != previousStats && Object.keys(storedStats).length > 0) {
          this.logger.debug("New stats: " + newStats);
        }
      }
    }]);
    return StatisticsGatherer;
  }();
  
  var StatisticsStorage = function () {
    function StatisticsStorage(key) {
      classCallCheck(this, StatisticsStorage);
  
      this.key = key;
    }
  
    createClass(StatisticsStorage, [{
      key: 'read',
      value: function read() {
        var localStorageStatsString = localStorage.getItem(this.key);
        try {
          return JSON.parse(localStorageStatsString ? localStorageStatsString : '{}');
        } catch (e) {
          return {};
        }
      }
    }, {
      key: 'write',
      value: function write(data) {
        localStorage.setItem(this.key, data);
      }
    }, {
      key: 'clear',
      value: function clear() {
        localStorage.removeItem(this.key);
      }
    }, {
      key: 'isEmpty',
      value: function isEmpty() {
        var storedStats = this.read();
        var empty = true;
        Object.keys(storedStats).forEach(function (key) {
          if (Object.keys(storedStats[key]).length > 0) {
            empty = false;
          }
        });
  
        return empty;
      }
    }]);
    return StatisticsStorage;
  }();
  
  var StatisticsSender = function () {
    function StatisticsSender(url, logger) {
      classCallCheck(this, StatisticsSender);
  
      this.url = url;
      this.logger = logger;
    }
  
    createClass(StatisticsSender, [{
      key: 'send',
      value: function send(data, errorHandler) {
        var logger = this.logger;
  
        if (navigator.onLine === false) {
          logger.debug("Offline, can't send");
          errorHandler();
          return;
        }
        logger.debug("Sending data to " + this.url);
  
        var req = new XMLHttpRequest();
        req.withCredentials = true;
        req.addEventListener("load", function () {
          // Stats sent, nothing more to do
          logger.debug("Response: " + req.responseText);
        });
        req.addEventListener("error", function () {
          logger.debug("Send failed");
          errorHandler();
        });
        req.addEventListener("abort", function () {
          logger.debug("Send aborted");
          errorHandler();
        });
        req.open("POST", this.url);
        req.setRequestHeader("Content-Type", "application/json");
        req.send(data);
      }
    }]);
    return StatisticsSender;
  }();
  
  var StatisticsLogger = function () {
    function StatisticsLogger(id) {
      classCallCheck(this, StatisticsLogger);
  
      this.id = id;
    }
  
    createClass(StatisticsLogger, [{
      key: '_isDebug',
      value: function _isDebug() {
        return localStorage.getItem("vaadin." + this.id + ".debug");
      }
    }, {
      key: 'debug',
      value: function debug(msg) {
        if (this._isDebug()) {
          console.info(this.id + ": " + msg);
        }
      }
    }]);
    return StatisticsLogger;
  }();
  
  var UsageStatistics = function () {
    function UsageStatistics() {
      classCallCheck(this, UsageStatistics);
  
      this.now = new Date();
      this.timeNow = this.now.getTime();
      this.gatherDelay = 10; // Delay between loading this file and gathering stats
      this.initialDelay = 24 * 60 * 60;
  
      this.logger = new StatisticsLogger("statistics");
      this.storage = new StatisticsStorage("vaadin.statistics.basket");
      this.gatherer = new StatisticsGatherer(this.logger);
      this.sender = new StatisticsSender("https://tools.vaadin.com/usage-stats/submit", this.logger);
    }
  
    createClass(UsageStatistics, [{
      key: 'maybeGatherAndSend',
      value: function maybeGatherAndSend() {
        var _this = this;
  
        if (localStorage.getItem(UsageStatistics.optOutKey)) {
          return;
        }
        this.gatherer.gather(this.storage);
        setTimeout(function () {
          _this.maybeSend();
        }, this.gatherDelay * 1000);
      }
    }, {
      key: 'lottery',
      value: function lottery() {
        return true;
      }
    }, {
      key: 'currentMonth',
      value: function currentMonth() {
        return this.now.getYear() * 12 + this.now.getMonth();
      }
    }, {
      key: 'maybeSend',
      value: function maybeSend() {
        var firstUse = Number(localStorage.getItem(UsageStatistics.firstUseKey));
        var monthProcessed = Number(localStorage.getItem(UsageStatistics.monthProcessedKey));
  
        if (!firstUse) {
          // Use a grace period to avoid interfering with tests, incognito mode etc
          firstUse = this.timeNow;
          localStorage.setItem(UsageStatistics.firstUseKey, firstUse);
        }
  
        if (this.timeNow < firstUse + this.initialDelay * 1000) {
          this.logger.debug("No statistics will be sent until the initial delay of " + this.initialDelay + "s has passed");
          return;
        }
        if (this.currentMonth() <= monthProcessed) {
          this.logger.debug("This month has already been processed");
          return;
        }
        localStorage.setItem(UsageStatistics.monthProcessedKey, this.currentMonth());
        // Use random sampling
        if (this.lottery()) {
          this.logger.debug("Congratulations, we have a winner!");
        } else {
          this.logger.debug("Sorry, no stats from you this time");
          return;
        }
  
        this.send();
      }
    }, {
      key: 'send',
      value: function send() {
        // Ensure we have the latest data
        this.gatherer.gather(this.storage);
  
        // Read, send and clean up
        var data = this.storage.read();
        data["firstUse"] = Number(localStorage.getItem(UsageStatistics.firstUseKey));
        data["usageStatisticsVersion"] = UsageStatistics.version;
        var info = 'This request contains usage statistics gathered from the application running in development mode. \n\nStatistics gathering is automatically disabled and excluded from production builds.\n\nFor details and to opt-out, see https://github.com/vaadin/vaadin-usage-statistics.\n\n\n\n';
        var self = this;
        this.sender.send(info + JSON.stringify(data), function () {
          // Revert the 'month processed' flag
          localStorage.setItem(UsageStatistics.monthProcessedKey, self.currentMonth() - 1);
        });
      }
    }], [{
      key: 'version',
      get: function get$1() {
        return '2.1.2';
      }
    }, {
      key: 'firstUseKey',
      get: function get$1() {
        return 'vaadin.statistics.firstuse';
      }
    }, {
      key: 'monthProcessedKey',
      get: function get$1() {
        return 'vaadin.statistics.monthProcessed';
      }
    }, {
      key: 'optOutKey',
      get: function get$1() {
        return 'vaadin.statistics.optout';
      }
    }]);
    return UsageStatistics;
  }();
  
  try {
    window.Vaadin = window.Vaadin || {};
    window.Vaadin.usageStatsChecker = window.Vaadin.usageStatsChecker || new UsageStatistics();
    window.Vaadin.usageStatsChecker.maybeGatherAndSend();
  } catch (e) {
    // Intentionally ignored as this is not a problem in the app being developed
  }
  
  }());
  
    vaadin-dev-mode:end **/
}
var usageStatistics = function() {
  if (typeof runIfDevelopmentMode === "function") {
    return runIfDevelopmentMode(maybeGatherAndSendStats);
  }
};
// node_modules/@vaadin/component-base/src/element-mixin.js
if (!window.Vaadin) {
  window.Vaadin = {};
}
if (!window.Vaadin.registrations) {
  window.Vaadin.registrations = [];
}
if (!window.Vaadin.developmentModeCallback) {
  window.Vaadin.developmentModeCallback = {};
}
window.Vaadin.developmentModeCallback["vaadin-usage-statistics"] = function() {
  usageStatistics();
};
var statsJob;
var registered = new Set;
var ElementMixin = (superClass) => class VaadinElementMixin extends DirMixin(superClass) {
  static finalize() {
    super.finalize();
    const { is: is2 } = this;
    if (is2 && !registered.has(is2)) {
      window.Vaadin.registrations.push(this);
      registered.add(is2);
      const callback = window.Vaadin.developmentModeCallback;
      if (callback) {
        statsJob = Debouncer.debounce(statsJob, idlePeriod, () => {
          callback["vaadin-usage-statistics"]();
        });
        enqueueDebouncer(statsJob);
      }
    }
  }
  constructor() {
    super();
    if (document.doctype === null) {
      console.warn('Vaadin components require the "standards mode" declaration. Please add <!DOCTYPE html> to the HTML document.');
    }
  }
};

// node_modules/@vaadin/vaadin-themable-mixin/src/css-property-observer.js
class CSSPropertyObserver extends EventTarget {
  #root;
  #properties = new Set;
  #styleSheet;
  #isConnected = false;
  constructor(root) {
    super();
    this.#root = root;
    this.#styleSheet = new CSSStyleSheet;
  }
  #handleTransitionEvent(event) {
    const { propertyName } = event;
    if (this.#properties.has(propertyName)) {
      this.dispatchEvent(new CustomEvent("property-changed", { detail: { propertyName } }));
    }
  }
  observe(property) {
    this.connect();
    if (this.#properties.has(property)) {
      return;
    }
    this.#properties.add(property);
    this.#styleSheet.replaceSync(`
      :root::before, :host::before {
        content: '' !important;
        position: absolute !important;
        top: -9999px !important;
        left: -9999px !important;
        visibility: hidden !important;
        transition: 1ms allow-discrete step-end !important;
        transition-property: ${[...this.#properties].join(", ")} !important;
      }
    `);
  }
  connect() {
    if (this.#isConnected) {
      return;
    }
    this.#root.adoptedStyleSheets.unshift(this.#styleSheet);
    this.#rootHost.addEventListener("transitionstart", (event) => this.#handleTransitionEvent(event));
    this.#rootHost.addEventListener("transitionend", (event) => this.#handleTransitionEvent(event));
    this.#isConnected = true;
  }
  disconnect() {
    this.#properties.clear();
    this.#root.adoptedStyleSheets = this.#root.adoptedStyleSheets.filter((s) => s !== this.#styleSheet);
    this.#rootHost.removeEventListener("transitionstart", this.#handleTransitionEvent);
    this.#rootHost.removeEventListener("transitionend", this.#handleTransitionEvent);
    this.#isConnected = false;
  }
  get #rootHost() {
    return this.#root.documentElement ?? this.#root.host;
  }
  static for(root) {
    root.__cssPropertyObserver ||= new CSSPropertyObserver(root);
    return root.__cssPropertyObserver;
  }
}

// node_modules/@vaadin/vaadin-themable-mixin/src/css-utils.js
function getEffectiveStyles(component) {
  const { baseStyles, themeStyles, elementStyles, lumoInjector } = component.constructor;
  const lumoStyleSheet = component.__lumoStyleSheet;
  if (lumoStyleSheet && (baseStyles || themeStyles)) {
    return [...lumoInjector.includeBaseStyles ? baseStyles : [], lumoStyleSheet, ...themeStyles];
  }
  return [lumoStyleSheet, ...elementStyles].filter(Boolean);
}
function applyInstanceStyles(component) {
  adoptStyles(component.shadowRoot, getEffectiveStyles(component));
}
function injectLumoStyleSheet(component, styleSheet) {
  component.__lumoStyleSheet = styleSheet;
  applyInstanceStyles(component);
}
function removeLumoStyleSheet(component) {
  component.__lumoStyleSheet = undefined;
  applyInstanceStyles(component);
}

// node_modules/@vaadin/component-base/src/warnings.js
var issuedWarnings = new Set;
function issueWarning4(warning) {
  if (issuedWarnings.has(warning)) {
    return;
  }
  issuedWarnings.add(warning);
  console.warn(warning);
}

// node_modules/@vaadin/vaadin-themable-mixin/src/lumo-modules.js
var cache = new WeakMap;
function getRuleMediaText(rule) {
  try {
    return rule.media.mediaText;
  } catch {
    issueWarning4('[LumoInjector] Browser denied to access property "mediaText" for some CSS rules, so they were skipped.');
    return "";
  }
}
function getStyleSheetRules(styleSheet) {
  try {
    return styleSheet.cssRules;
  } catch {
    issueWarning4('[LumoInjector] Browser denied to access property "cssRules" for some CSS stylesheets, so they were skipped.');
    return [];
  }
}
function parseStyleSheet(styleSheet, result = {
  tags: new Map,
  modules: new Map
}) {
  for (const rule of getStyleSheetRules(styleSheet)) {
    if (rule instanceof CSSImportRule) {
      const mediaText = getRuleMediaText(rule);
      if (mediaText.startsWith("lumo_")) {
        result.modules.set(mediaText, [...rule.styleSheet.cssRules]);
      } else {
        parseStyleSheet(rule.styleSheet, result);
      }
      continue;
    }
    if (rule instanceof CSSMediaRule) {
      const mediaText = getRuleMediaText(rule);
      if (mediaText.startsWith("lumo_")) {
        result.modules.set(mediaText, [...rule.cssRules]);
      }
      continue;
    }
    if (rule instanceof CSSStyleRule && rule.cssText.includes("-inject")) {
      for (const property of rule.style) {
        const tagName = property.match(/^--_lumo-(.*)-inject-modules$/u)?.[1];
        if (!tagName) {
          continue;
        }
        const value = rule.style.getPropertyValue(property);
        result.tags.set(tagName, value.split(",").map((module) => module.trim().replace(/'|"/gu, "")));
      }
      continue;
    }
  }
  return result;
}
function parseStyleSheets(styleSheets) {
  let tags = new Map;
  let modules = new Map;
  for (const styleSheet of styleSheets) {
    let result = cache.get(styleSheet);
    if (!result) {
      result = parseStyleSheet(styleSheet);
      cache.set(styleSheet, result);
    }
    tags = new Map([...tags, ...result.tags]);
    modules = new Map([...modules, ...result.modules]);
  }
  return { tags, modules };
}

// node_modules/@vaadin/vaadin-themable-mixin/src/lumo-injector.js
function getLumoInjectorPropName(lumoInjector) {
  return `--_lumo-${lumoInjector.is}-inject`;
}

class LumoInjector {
  #root;
  #cssPropertyObserver;
  #styleSheetsByTag = new Map;
  #componentsByTag = new Map;
  constructor(root = document) {
    this.#root = root;
    this.handlePropertyChange = this.handlePropertyChange.bind(this);
    this.#cssPropertyObserver = CSSPropertyObserver.for(root);
    this.#cssPropertyObserver.addEventListener("property-changed", this.handlePropertyChange);
  }
  disconnect() {
    this.#cssPropertyObserver.removeEventListener("property-changed", this.handlePropertyChange);
    this.#styleSheetsByTag.clear();
    this.#componentsByTag.values().forEach((components) => components.forEach(removeLumoStyleSheet));
  }
  forceUpdate() {
    for (const tagName of this.#styleSheetsByTag.keys()) {
      this.#updateStyleSheet(tagName);
    }
  }
  componentConnected(component) {
    const { lumoInjector } = component.constructor;
    const { is: tagName } = lumoInjector;
    this.#componentsByTag.set(tagName, this.#componentsByTag.get(tagName) ?? new Set);
    this.#componentsByTag.get(tagName).add(component);
    const stylesheet = this.#styleSheetsByTag.get(tagName);
    if (stylesheet) {
      if (stylesheet.cssRules.length > 0) {
        injectLumoStyleSheet(component, stylesheet);
      }
      return;
    }
    this.#initStyleSheet(tagName);
    const propName = getLumoInjectorPropName(lumoInjector);
    this.#cssPropertyObserver.observe(propName);
  }
  componentDisconnected(component) {
    const { is: tagName } = component.constructor.lumoInjector;
    this.#componentsByTag.get(tagName)?.delete(component);
    removeLumoStyleSheet(component);
  }
  handlePropertyChange(event) {
    const { propertyName } = event.detail;
    const tagName = propertyName.match(/^--_lumo-(.*)-inject$/u)?.[1];
    if (tagName) {
      this.#updateStyleSheet(tagName);
    }
  }
  #initStyleSheet(tagName) {
    this.#styleSheetsByTag.set(tagName, new CSSStyleSheet);
    this.#updateStyleSheet(tagName);
  }
  #updateStyleSheet(tagName) {
    const { tags, modules } = parseStyleSheets(this.#rootStyleSheets);
    const cssText = (tags.get(tagName) ?? []).flatMap((moduleName) => modules.get(moduleName) ?? []).map((rule) => rule.cssText).join(`
`);
    const stylesheet = this.#styleSheetsByTag.get(tagName);
    stylesheet.replaceSync(cssText);
    this.#componentsByTag.get(tagName)?.forEach((component) => {
      if (cssText) {
        injectLumoStyleSheet(component, stylesheet);
      } else {
        removeLumoStyleSheet(component);
      }
    });
  }
  get #rootStyleSheets() {
    let styleSheets = new Set;
    for (const root of [this.#root, document]) {
      styleSheets = styleSheets.union(new Set(root.styleSheets));
      styleSheets = styleSheets.union(new Set(root.adoptedStyleSheets));
    }
    return [...styleSheets];
  }
}

// node_modules/@vaadin/vaadin-themable-mixin/lumo-injection-mixin.js
var registeredProperties = new Set;
function findRoot(element) {
  const root = element.getRootNode();
  if (root.host && root.host.constructor.version) {
    return findRoot(root.host);
  }
  return root;
}
var LumoInjectionMixin = (superClass) => class LumoInjectionMixinClass extends superClass {
  static finalize() {
    super.finalize();
    const propName = getLumoInjectorPropName(this.lumoInjector);
    if (this.is && !registeredProperties.has(propName)) {
      registeredProperties.add(propName);
      CSS.registerProperty({
        name: propName,
        syntax: "<number>",
        inherits: true,
        initialValue: "0"
      });
    }
  }
  static get lumoInjector() {
    return {
      is: this.is,
      includeBaseStyles: false
    };
  }
  connectedCallback() {
    super.connectedCallback();
    const root = findRoot(this);
    if (root.__lumoInjectorDisabled) {
      return;
    }
    if (this.isConnected) {
      root.__lumoInjector ||= new LumoInjector(root);
      this.__lumoInjector = root.__lumoInjector;
      this.__lumoInjector.componentConnected(this);
    }
  }
  disconnectedCallback() {
    super.disconnectedCallback();
    if (this.__lumoInjector) {
      this.__lumoInjector.componentDisconnected(this);
      this.__lumoInjector = undefined;
    }
  }
};

// node_modules/@vaadin/vaadin-themable-mixin/vaadin-theme-property-mixin.js
var ThemePropertyMixin = (superClass) => class VaadinThemePropertyMixin extends superClass {
  static get properties() {
    return {
      _theme: {
        type: String,
        readOnly: true
      }
    };
  }
  static get observedAttributes() {
    return [...super.observedAttributes, "theme"];
  }
  attributeChangedCallback(name, oldValue, newValue) {
    super.attributeChangedCallback(name, oldValue, newValue);
    if (name === "theme") {
      this._set_theme(newValue);
    }
  }
};

// node_modules/@vaadin/vaadin-themable-mixin/vaadin-themable-mixin.js
var themeRegistry = [];
var themableInstances = new Set;
var themableTagNames = new Set;
function classHasThemes(elementClass) {
  return elementClass && Object.prototype.hasOwnProperty.call(elementClass, "__themes");
}
function matchesThemeFor(themeFor, tagName) {
  return (themeFor || "").split(" ").some((themeForToken) => {
    return new RegExp(`^${themeForToken.split("*").join(".*")}$`, "u").test(tagName);
  });
}
function getCssText(styles) {
  return styles.map((style) => style.cssText).join(`
`);
}
var STYLE_ID = "vaadin-themable-mixin-style";
function addStylesToTemplate(styles, template) {
  const styleEl = document.createElement("style");
  styleEl.id = STYLE_ID;
  styleEl.textContent = getCssText(styles);
  template.content.appendChild(styleEl);
}
function getIncludePriority(moduleName = "") {
  let includePriority = 0;
  if (moduleName.startsWith("lumo-") || moduleName.startsWith("material-")) {
    includePriority = 1;
  } else if (moduleName.startsWith("vaadin-")) {
    includePriority = 2;
  }
  return includePriority;
}
function getIncludedStyles(theme) {
  const includedStyles = [];
  if (theme.include) {
    [].concat(theme.include).forEach((includeModuleId) => {
      const includedTheme = themeRegistry.find((s) => s.moduleId === includeModuleId);
      if (includedTheme) {
        includedStyles.push(...getIncludedStyles(includedTheme), ...includedTheme.styles);
      } else {
        console.warn(`Included moduleId ${includeModuleId} not found in style registry`);
      }
    }, theme.styles);
  }
  return includedStyles;
}
function getThemes(tagName) {
  const defaultModuleName = `${tagName}-default-theme`;
  const themes = themeRegistry.filter((theme) => theme.moduleId !== defaultModuleName && matchesThemeFor(theme.themeFor, tagName)).map((theme) => ({
    ...theme,
    styles: [...getIncludedStyles(theme), ...theme.styles],
    includePriority: getIncludePriority(theme.moduleId)
  })).sort((themeA, themeB) => themeB.includePriority - themeA.includePriority);
  if (themes.length > 0) {
    return themes;
  }
  return themeRegistry.filter((theme) => theme.moduleId === defaultModuleName);
}
var ThemableMixin = (superClass) => class VaadinThemableMixin extends ThemePropertyMixin(superClass) {
  constructor() {
    super();
    themableInstances.add(new WeakRef(this));
  }
  static finalize() {
    super.finalize();
    if (this.is) {
      themableTagNames.add(this.is);
    }
    if (this.elementStyles) {
      return;
    }
    const template = this.prototype._template;
    if (!template || classHasThemes(this)) {
      return;
    }
    addStylesToTemplate(this.getStylesForThis(), template);
  }
  static finalizeStyles(styles) {
    this.baseStyles = styles ? [styles].flat(Infinity) : [];
    this.themeStyles = this.getStylesForThis();
    return [...this.baseStyles, ...this.themeStyles];
  }
  static getStylesForThis() {
    const superClassThemes = superClass.__themes || [];
    const parent = Object.getPrototypeOf(this.prototype);
    const inheritedThemes = (parent ? parent.constructor.__themes : []) || [];
    this.__themes = [...superClassThemes, ...inheritedThemes, ...getThemes(this.is)];
    const themeStyles = this.__themes.flatMap((theme) => theme.styles);
    return themeStyles.filter((style, index) => index === themeStyles.lastIndexOf(style));
  }
};

// node_modules/@vaadin/component-base/src/styles/add-global-styles.js
var addGlobalStyles = (id, ...styles) => {
  const styleTag = document.createElement("style");
  styleTag.id = id;
  styleTag.textContent = styles.map((style) => style.toString()).join(`
`);
  document.head.insertAdjacentElement("afterbegin", styleTag);
};

// node_modules/@vaadin/component-base/src/styles/style-props.js
[
  "--vaadin-text-color",
  "--vaadin-text-color-disabled",
  "--vaadin-text-color-secondary",
  "--vaadin-border-color",
  "--vaadin-border-color-secondary",
  "--vaadin-background-color"
].forEach((propertyName) => {
  CSS.registerProperty({
    name: propertyName,
    syntax: "<color>",
    inherits: true,
    initialValue: "light-dark(black, white)"
  });
});
addGlobalStyles("vaadin-base", css`
    @layer vaadin.base {
      html {
        /* Background color */
        --vaadin-background-color: light-dark(#fff, #222);

        /* Container colors */
        --vaadin-background-container: color-mix(in oklab, var(--vaadin-text-color) 5%, var(--vaadin-background-color));
        --vaadin-background-container-strong: color-mix(
          in oklab,
          var(--vaadin-text-color) 10%,
          var(--vaadin-background-color)
        );

        /* Border colors */
        --vaadin-border-color-secondary: color-mix(in oklab, var(--vaadin-text-color) 24%, transparent);
        --vaadin-border-color: color-mix(in oklab, var(--vaadin-text-color) 48%, transparent); /* Above 3:1 contrast */

        /* Text colors */
        /* Above 3:1 contrast */
        --vaadin-text-color-disabled: color-mix(in oklab, var(--vaadin-text-color) 48%, transparent);
        /* Above 4.5:1 contrast */
        --vaadin-text-color-secondary: color-mix(in oklab, var(--vaadin-text-color) 68%, transparent);
        /* Above 7:1 contrast */
        --vaadin-text-color: light-dark(#1f1f1f, white);

        /* Padding */
        --vaadin-padding-xs: 6px;
        --vaadin-padding-s: 8px;
        --vaadin-padding-m: 12px;
        --vaadin-padding-l: 16px;
        --vaadin-padding-xl: 24px;
        --vaadin-padding-block-container: var(--vaadin-padding-xs);
        --vaadin-padding-inline-container: var(--vaadin-padding-s);

        /* Gap/spacing */
        --vaadin-gap-xs: 6px;
        --vaadin-gap-s: 8px;
        --vaadin-gap-m: 12px;
        --vaadin-gap-l: 16px;
        --vaadin-gap-xl: 24px;

        /* Border radius */
        --vaadin-radius-s: 3px;
        --vaadin-radius-m: 6px;
        --vaadin-radius-l: 12px;

        /* Focus outline */
        --vaadin-focus-ring-width: 2px;
        --vaadin-focus-ring-color: var(--vaadin-text-color);

        /* Icons, used as mask-image */
        --_vaadin-icon-arrow-up: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12 7-7 7 7"/><path d="M12 19V5"/></svg>');
        --_vaadin-icon-calendar: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>');
        --_vaadin-icon-checkmark: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" /></svg>');
        --_vaadin-icon-chevron-down: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>');
        --_vaadin-icon-clock: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 6v6l4 2"/><circle cx="12" cy="12" r="10"/></svg>');
        --_vaadin-icon-cross: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" /></svg>');
        --_vaadin-icon-drag: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"><path d="M11 7c0 .82843-.6716 1.5-1.5 1.5C8.67157 8.5 8 7.82843 8 7s.67157-1.5 1.5-1.5c.8284 0 1.5.67157 1.5 1.5Zm0 5c0 .8284-.6716 1.5-1.5 1.5-.82843 0-1.5-.6716-1.5-1.5s.67157-1.5 1.5-1.5c.8284 0 1.5.6716 1.5 1.5Zm0 5c0 .8284-.6716 1.5-1.5 1.5-.82843 0-1.5-.6716-1.5-1.5s.67157-1.5 1.5-1.5c.8284 0 1.5.6716 1.5 1.5Zm5-10c0 .82843-.6716 1.5-1.5 1.5S13 7.82843 13 7s.6716-1.5 1.5-1.5S16 6.17157 16 7Zm0 5c0 .8284-.6716 1.5-1.5 1.5S13 12.8284 13 12s.6716-1.5 1.5-1.5 1.5.6716 1.5 1.5Zm0 5c0 .8284-.6716 1.5-1.5 1.5S13 17.8284 13 17s.6716-1.5 1.5-1.5 1.5.6716 1.5 1.5Z" fill="currentColor"/></svg>');
        --_vaadin-icon-eye: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" /><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" /></svg>');
        --_vaadin-icon-eye-slash: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" /></svg>');
        --_vaadin-icon-fullscreen: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 3.75v4.5m0-4.5h4.5m-4.5 0L9 9M3.75 20.25v-4.5m0 4.5h4.5m-4.5 0L9 15M20.25 3.75h-4.5m4.5 0v4.5m0-4.5L15 9m5.25 11.25h-4.5m4.5 0v-4.5m0 4.5L15 15" /></svg>');
        --_vaadin-icon-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="3" rx="2" ry="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21"/></svg>');
        --_vaadin-icon-link: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>');
        --_vaadin-icon-menu: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" /></svg>');
        --_vaadin-icon-minus: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/></svg>');
        --_vaadin-icon-paper-airplane: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M6 12 3.269 3.125A59.769 59.769 0 0 1 21.485 12 59.768 59.768 0 0 1 3.27 20.875L5.999 12Zm0 0h7.5" /></svg>');
        --_vaadin-icon-pen: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"/><path d="m15 5 4 4"/></svg>');
        --_vaadin-icon-play: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M5.25 5.653c0-.856.917-1.398 1.667-.986l11.54 6.347a1.125 1.125 0 0 1 0 1.972l-11.54 6.347a1.125 1.125 0 0 1-1.667-.986V5.653Z" /></svg>');
        --_vaadin-icon-plus: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5v14"/></svg>');
        --_vaadin-icon-redo: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 7v6h-6"/><path d="M3 17a9 9 0 0 1 9-9 9 9 0 0 1 6 2.3l3 2.7"/></svg>');
        --_vaadin-icon-refresh: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"><path d="M22 10C22 10 19.995 7.26822 18.3662 5.63824C16.7373 4.00827 14.4864 3 12 3C7.02944 3 3 7.02944 3 12C3 16.9706 7.02944 21 12 21C16.1031 21 19.5649 18.2543 20.6482 14.5M22 10V4M22 10H16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>');
        --_vaadin-icon-resize: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><path fill-rule="evenodd" clip-rule="evenodd" d="M18.5303 7.46967c.2929.29289.2929.76777 0 1.06066L8.53033 18.5304c-.29289.2929-.76777.2929-1.06066 0s-.29289-.7678 0-1.0607L17.4697 7.46967c.2929-.29289.7677-.29289 1.0606 0Zm0 4.50003c.2929.2929.2929.7678 0 1.0607l-5.5 5.5c-.2929.2928-.7677.2928-1.0606 0-.2929-.2929-.2929-.7678 0-1.0607l5.4999-5.5c.2929-.2929.7678-.2929 1.0607 0Zm0 4.5c.2929.2928.2929.7677 0 1.0606l-1 1.0001c-.2929.2928-.7677.2929-1.0606 0-.2929-.2929-.2929-.7678 0-1.0607l1-1c.2929-.2929.7677-.2929 1.0606 0Z" fill="currentColor"/></svg>');
        --_vaadin-icon-sort: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="8" height="12" viewBox="0 0 8 12" fill="none"><path d="M7.49854 6.99951C7.92795 6.99951 8.15791 7.50528 7.87549 7.82861L4.37646 11.8296C4.17728 12.0571 3.82272 12.0571 3.62354 11.8296L0.125488 7.82861C-0.157248 7.50531 0.0719873 6.99956 0.501465 6.99951H7.49854ZM3.62354 0.17041C3.82275 -0.0573875 4.17725 -0.0573848 4.37646 0.17041L7.87549 4.17041C8.15825 4.49373 7.92806 5.00049 7.49854 5.00049L0.501465 4.99951C0.0719873 4.99946 -0.157248 4.49371 0.125488 4.17041L3.62354 0.17041Z" fill="black"/></svg>');
        --_vaadin-icon-undo: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7v6h6"/><path d="M21 17a9 9 0 0 0-9-9 9 9 0 0 0-6 2.3L3 13"/></svg>');
        --_vaadin-icon-upload: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v12"/><path d="m17 8-5-5-5 5"/><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/></svg>');
        --_vaadin-icon-user: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>');
        --_vaadin-icon-warn: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"/><path d="M12 9v4"/><path d="M12 17h.01"/></svg>');

        /* Cursors for interactive elements */
        --vaadin-clickable-cursor: pointer;
        --vaadin-disabled-cursor: not-allowed;

        /* Use units so that the values can be used in calc() */
        --safe-area-inset-top: env(safe-area-inset-top, 0px);
        --safe-area-inset-right: env(safe-area-inset-right, 0px);
        --safe-area-inset-bottom: env(safe-area-inset-bottom, 0px);
        --safe-area-inset-left: env(safe-area-inset-left, 0px);
      }

      @supports not (color: hsl(0 0 0)) {
        html {
          --_vaadin-safari-17-deg: 1deg;
        }
      }

      @media (forced-colors: active) {
        html {
          --vaadin-background-color: Canvas;
          --vaadin-border-color: CanvasText;
          --vaadin-border-color-secondary: CanvasText;
          --vaadin-text-color-disabled: CanvasText;
          --vaadin-text-color-secondary: CanvasText;
          --vaadin-text-color: CanvasText;
          --vaadin-icon-color: CanvasText;
          --vaadin-focus-ring-color: Highlight;
        }
      }
    }
  `);

// node_modules/@vaadin/grid/src/styles/vaadin-grid-base-styles.js
var gridStyles = css`
  /* stylelint-disable no-duplicate-selectors */
  :host {
    display: flex;
    max-width: 100%;
    height: 400px;
    min-height: var(--_grid-min-height, 0);
    flex: 1 1 auto;
    align-self: stretch;
    position: relative;
    box-sizing: border-box;
    overflow: hidden;
    -webkit-tap-highlight-color: transparent;
    background: var(--vaadin-grid-background, var(--vaadin-background-color));
    border: var(--vaadin-grid-border-width, 1px) solid var(--_border-color);
    cursor: default;
    --_border-color: var(--vaadin-grid-border-color, var(--vaadin-border-color-secondary));
    --_row-border-width: var(--vaadin-grid-row-border-width, 1px);
    --_column-border-width: var(--vaadin-grid-column-border-width, 0px);
    --_default-cell-padding: var(--vaadin-padding-block-container) var(--vaadin-padding-inline-container);
    border-radius: var(--vaadin-grid-border-radius, var(--vaadin-radius-m));
  }

  :host([hidden]),
  [hidden] {
    display: none !important;
  }

  :host([disabled]) {
    pointer-events: none;
    opacity: 0.7;
  }

  /* Variant: No outer border */
  :host([theme~='no-border']) {
    border-width: 0;
    border-radius: 0;
  }

  :host([all-rows-visible]) {
    height: auto;
    align-self: flex-start;
    min-height: auto;
    flex-grow: 0;
    flex-shrink: 0;
    width: 100%;
  }

  #scroller {
    contain: layout;
    position: relative;
    display: flex;
    width: 100%;
    min-width: 0;
    min-height: 0;
    align-self: stretch;
    overflow: hidden;
  }

  #items {
    flex-grow: 1;
    flex-shrink: 0;
    display: block;
    position: sticky;
    width: 100%;
    left: 0;
    min-height: 1px;
    z-index: 1;
  }

  #table {
    display: flex;
    flex-direction: column;
    width: 100%;
    overflow: auto;
    position: relative;
    border-radius: inherit;
    /* Workaround for a Chrome bug: new stacking context here prevents the scrollbar from getting hidden */
    z-index: 0;
  }

  [no-scrollbars]:is([safari], [firefox]) #table {
    overflow: hidden;
  }

  #header,
  #footer {
    display: block;
    position: sticky;
    left: 0;
    width: 100%;
    z-index: 2;
  }

  :host([dir='rtl']) #items,
  :host([dir='rtl']) #header,
  :host([dir='rtl']) #footer {
    left: auto;
  }

  #header {
    top: 0;
  }

  #footer {
    bottom: 0;
  }

  th {
    text-align: inherit;
  }

  #header th,
  .reorder-ghost {
    font-size: var(--vaadin-grid-header-font-size, 1em);
    font-weight: var(--vaadin-grid-header-font-weight, 500);
    color: var(--vaadin-grid-header-text-color, var(--vaadin-text-color));
  }

  .row {
    display: flex;
    width: 100%;
    box-sizing: border-box;
    margin: 0;
    position: relative;
  }

  .row:not(:focus-within) {
    --_non-focused-row-none: none;
  }

  .body-row[loading] .body-cell ::slotted(vaadin-grid-cell-content) {
    visibility: hidden;
  }

  [column-rendering='lazy'] .body-cell:not([frozen]):not([frozen-to-end]) {
    transform: translateX(var(--_grid-lazy-columns-start));
  }

  #items .row:empty {
    height: 100%;
  }

  .cell {
    padding: 0;
    box-sizing: border-box;
  }

  .cell:where(:not(.details-cell)) {
    flex-shrink: 0;
    flex-grow: 1;
    display: flex;
    width: 100%;
    position: relative;
    align-items: center;
    white-space: nowrap;
  }

  /*
    Block borders

    ::after - row and cell focus outline
    ::before - header bottom and footer top borders that only appear when scrolling
  */

  .row::after {
    top: 0;
    bottom: calc(var(--_row-border-width) * -1);
  }

  .body-row {
    scroll-margin-bottom: var(--_row-border-width);
  }

  .cell {
    border-block: var(--_row-border-width) var(--_border-color);
    border-top-style: solid;
  }

  .cell::after {
    top: calc(var(--_row-border-width) * -1);
    bottom: calc(var(--_row-border-width) * -1);
  }

  /* Block borders / Last header row and first footer row */

  .last-header-row::before,
  .first-footer-row::before {
    position: absolute;
    inset-inline: 0;
    border-block: var(--_row-border-width) var(--_border-color);
    transform: translateX(var(--_grid-horizontal-scroll-position));
  }

  /* Block borders / First header row */

  .first-header-row-cell {
    border-top-style: none;
  }

  .first-header-row-cell::after {
    top: 0;
  }

  /* Block borders / Last header row */

  :host([overflow~='top']) .last-header-row::before {
    content: '';
    bottom: calc(var(--_row-border-width) * -1);
    border-bottom-style: solid;
  }

  /* Block borders / First body row */

  #table:not([has-header]) .first-row-cell {
    border-top-style: none;
  }

  #table:not([has-header]) .first-row-cell::after {
    top: 0;
  }

  /* Block borders / Last body row */

  .last-row::after {
    bottom: 0;
  }

  .last-row .details-cell,
  .last-row-cell:not(.details-opened-row-cell) {
    border-bottom-style: solid;
  }

  /* Block borders / Last body row without footer */

  :host([all-rows-visible]),
  :host([overflow~='top']),
  :host([overflow~='bottom']) {
    #table:not([has-footer]) .last-row .details-cell,
    #table:not([has-footer]) .last-row-cell:not(.details-opened-row-cell) {
      border-bottom-style: none;

      &::after {
        bottom: 0;
      }
    }
  }

  /* Block borders / First footer row */

  .first-footer-row::after {
    top: calc(var(--_row-border-width) * -1);
  }

  .first-footer-row-cell {
    border-top-style: none;
  }

  :host([overflow~='bottom']),
  :host(:not([overflow~='top']):not([all-rows-visible])) #scroller:not([empty-state]) {
    .first-footer-row::before {
      content: '';
      top: calc(var(--_row-border-width) * -1);
      border-top-style: solid;
    }
  }

  /* Block borders / Last footer row */

  .last-footer-row::after,
  .last-footer-row-cell::after {
    bottom: 0;
  }

  /* Inline borders */

  .cell {
    border-inline: var(--_column-border-width) var(--_border-color);
  }

  .header-cell:not(.first-column-cell),
  .footer-cell:not(.first-column-cell),
  .body-cell:not(.first-column-cell) {
    border-inline-start-style: solid;
  }

  .last-frozen-cell:not(.last-column-cell) {
    border-inline-end-style: solid;

    & + .cell {
      border-inline-start-style: none;
    }
  }

  /* Row and cell background */

  .row {
    background-color: var(--vaadin-grid-row-background-color, var(--vaadin-background-color));
  }

  .cell {
    --_cell-background-image: linear-gradient(
      var(--vaadin-grid-cell-background-color, transparent),
      var(--vaadin-grid-cell-background-color, transparent)
    );

    background-color: inherit;
    background-repeat: no-repeat;
    background-origin: padding-box;
    background-image: var(--_cell-background-image);
  }

  .body-cell {
    --_cell-highlight-background-image: linear-gradient(
      var(--vaadin-grid-row-highlight-background-color, transparent),
      var(--vaadin-grid-row-highlight-background-color, transparent)
    );

    background-image:
      var(--_row-hover-background-image, none), var(--_row-selected-background-image, none),
      var(--_cell-highlight-background-image, none), var(--_row-odd-background-image, none),
      var(--_cell-background-image, none);
  }

  .selected-row {
    --_row-selected-background-color: var(
      --vaadin-grid-row-selected-background-color,
      color-mix(in srgb, currentColor 8%, transparent)
    );
    --_row-selected-background-image: linear-gradient(
      var(--_row-selected-background-color),
      var(--_row-selected-background-color)
    );
  }

  @media (any-hover: hover) {
    .body-row:hover {
      --_row-hover-background-color: var(--vaadin-grid-row-hover-background-color, transparent);
      --_row-hover-background-image: linear-gradient(
        var(--_row-hover-background-color),
        var(--_row-hover-background-color)
      );
    }
  }

  :host([theme~='row-stripes']) .odd-row {
    --_row-odd-background-color: var(
      --vaadin-grid-row-odd-background-color,
      color-mix(in srgb, var(--vaadin-text-color) 4%, transparent)
    );
    --_row-odd-background-image: linear-gradient(var(--_row-odd-background-color), var(--_row-odd-background-color));
  }

  /* Variant: wrap cell contents */

  :host([theme~='wrap-cell-content']) .cell:not(.details-cell) {
    white-space: normal;
  }

  /* Raise highlighted rows above others */
  .row,
  .frozen-cell,
  .frozen-to-end-cell {
    &:focus,
    &:focus-within {
      z-index: 3;
    }
  }

  .details-cell {
    position: absolute;
    bottom: 0;
    width: 100%;
  }

  .cell ::slotted(vaadin-grid-cell-content) {
    display: block;
    overflow: hidden;
    text-overflow: var(--vaadin-grid-cell-text-overflow, ellipsis);
    padding: var(--vaadin-grid-cell-padding, var(--_default-cell-padding));
    flex: 1;
    min-height: 1lh;
    min-width: 0;
  }

  [frozen],
  [frozen-to-end] {
    z-index: 2;
  }

  /* Empty state */
  #scroller:not([empty-state]) #emptystatebody,
  #scroller[empty-state] #items {
    display: none;
  }

  #emptystatebody {
    display: flex;
    position: sticky;
    inset: 0;
    flex: 1;
    overflow: hidden;
  }

  #emptystaterow {
    display: flex;
    flex: 1;
  }

  #emptystatecell {
    display: block;
    flex: 1;
    overflow: auto;
    padding: var(--vaadin-grid-cell-padding, var(--_default-cell-padding));
    outline: none;
    border-block: var(--_row-border-width) var(--_border-color);
  }

  #table[has-header] #emptystatecell {
    border-top-style: solid;
  }

  #table[has-footer] #emptystatecell {
    border-bottom-style: solid;
  }

  #emptystatecell:focus-visible {
    outline: var(--vaadin-focus-ring-width) solid var(--vaadin-focus-ring-color);
    outline-offset: calc(var(--vaadin-focus-ring-width) * -1);
  }

  /* Reordering styles */
  :host([reordering]) .cell ::slotted(vaadin-grid-cell-content),
  :host([reordering]) .resize-handle,
  #scroller[no-content-pointer-events] .cell ::slotted(vaadin-grid-cell-content) {
    pointer-events: none;
  }

  .reorder-ghost {
    visibility: hidden;
    position: fixed;
    pointer-events: none;
    box-shadow:
      0 0 0 1px hsla(0deg, 0%, 0%, 0.2),
      0 8px 24px -2px hsla(0deg, 0%, 0%, 0.2);
    padding: var(--vaadin-grid-cell-padding, var(--_default-cell-padding)) !important;
    border-radius: 3px;

    /* Prevent overflowing the grid in Firefox */
    top: 0;
    inset-inline-start: 0;
  }

  :host([reordering]) {
    -webkit-user-select: none;
    user-select: none;
  }

  :host([reordering]) .cell {
    /* TODO expose a custom property to control this */
    --_reorder-curtain-filter: brightness(0.9) contrast(1.1);
  }

  :host([reordering]) .cell::after {
    content: '';
    position: absolute;
    inset: 0;
    z-index: 1;
    -webkit-backdrop-filter: var(--_reorder-curtain-filter);
    backdrop-filter: var(--_reorder-curtain-filter);
    outline: 0;
  }

  :host([reordering]) .cell[reorder-status='allowed'] {
    /* TODO expose a custom property to control this */
    --_reorder-curtain-filter: brightness(0.94) contrast(1.07);
  }

  :host([reordering]) .cell[reorder-status='dragging'] {
    --_reorder-curtain-filter: none;
  }

  /* Resizing styles */
  .resize-handle {
    position: absolute;
    top: 0;
    inset-inline-end: 0;
    height: 100%;
    cursor: col-resize;
    z-index: 1;
    opacity: 0;
    width: var(--vaadin-focus-ring-width);
    background: var(--vaadin-grid-column-resize-handle-color, var(--vaadin-focus-ring-color));
    transition: opacity 0.2s;
    translate: var(--_column-border-width);
  }

  .last-column-cell .resize-handle {
    translate: 0;
  }

  :host(:not([reordering])) *:not([column-resizing]) .resize-handle:hover,
  .resize-handle:active {
    opacity: 1;
    transition-delay: 0.15s;
  }

  .resize-handle::before {
    position: absolute;
    content: '';
    height: 100%;
    width: 16px;
    translate: calc(-50% + var(--vaadin-focus-ring-width) / 2);
  }

  :host([dir='rtl']) .resize-handle::before {
    translate: calc(50% - var(--vaadin-focus-ring-width) / 2);
  }

  [first-frozen-to-end] .resize-handle::before,
  :is([last-column], [last-frozen]) .resize-handle::before {
    width: 8px;
    translate: 0;
  }

  :is([last-column], [last-frozen]) .resize-handle::before {
    inset-inline-end: 0;
  }

  [frozen-to-end] :is(.resize-handle, .resize-handle::before) {
    inset-inline: 0 auto;
  }

  [frozen-to-end] .resize-handle {
    translate: calc(var(--_column-border-width) * -1);
  }

  [first-frozen-to-end] {
    margin-inline-start: auto;
  }

  #scroller:is([column-resizing], [range-selecting]) {
    -webkit-user-select: none;
    user-select: none;
  }

  /* Focus outline element, also used for d'n'd indication */
  :is(.row, .cell)::after {
    position: absolute;
    z-index: 3;
    inset-inline: 0;
    pointer-events: none;
    outline: var(--vaadin-focus-ring-width) solid var(--vaadin-focus-ring-color);
    outline-offset: calc(var(--vaadin-focus-ring-width) * -1);
  }

  .row::after {
    transform: translateX(var(--_grid-horizontal-scroll-position));
  }

  .cell:where(:not(.details-cell))::after {
    inset-inline: calc(var(--_column-border-width) * -1);
  }

  .first-column-cell::after {
    inset-inline-start: 0;
  }

  .last-column-cell::after {
    inset-inline-end: 0;
  }

  :host([navigating]) .row:focus,
  :host([navigating]) .cell:focus {
    outline: 0;
  }

  .row:focus-visible,
  .cell:focus-visible {
    outline: 0;
  }

  .row:focus-visible::after,
  .cell:focus-visible::after,
  :host([navigating]) .row:focus::after,
  :host([navigating]) .cell:focus::after {
    content: '';
  }

  /* Drag'n'drop styles */
  :host([dragover]) {
    outline: var(--vaadin-focus-ring-width) solid var(--vaadin-focus-ring-color);
    outline-offset: calc(var(--vaadin-grid-border-width, 1px) * -1);
  }

  .row[dragover] {
    z-index: 100 !important;
  }

  .row[dragover]::after {
    content: '';
  }

  .row[dragover='above']::after {
    outline: 0;
    border-top: var(--vaadin-focus-ring-width) solid var(--vaadin-focus-ring-color);
  }

  .row:not(.first-row)[dragover='above']::after {
    top: calc(var(--vaadin-focus-ring-width) / -2);
  }

  .row[dragover='below']::after {
    outline: 0;
    border-bottom: var(--vaadin-focus-ring-width) solid var(--vaadin-focus-ring-color);
  }

  .row:not(.last-row)[dragover='below']::after {
    bottom: calc(var(--vaadin-focus-ring-width) / -2);
  }

  .row[dragstart] .cell {
    border-block: none !important;
    padding-block: var(--_row-border-width) !important;
  }

  .row[dragstart] .cell[last-column] {
    border-radius: 0 3px 3px 0;
  }

  .row[dragstart] .cell[first-column] {
    border-radius: 3px 0 0 3px;
  }

  /* Indicates the number of dragged rows */
  /* TODO export custom properties to control styles */
  #scroller .row[dragstart]:not([dragstart=''])::before {
    position: absolute;
    left: var(--_grid-drag-start-x);
    top: var(--_grid-drag-start-y);
    z-index: 100;
    content: attr(dragstart);
    box-sizing: border-box;
    padding: 0.3em;
    color: white;
    background-color: red;
    border-radius: 1em;
    font-size: 0.75rem;
    line-height: 1;
    font-weight: 500;
    min-width: 1.6em;
    text-align: center;
  }

  /* Sizer styles */
  #sizer {
    display: flex;
    visibility: hidden;
  }

  #sizer .details-cell,
  #sizer .cell ::slotted(vaadin-grid-cell-content) {
    display: none !important;
  }

  #sizer .cell {
    display: block;
    flex-shrink: 0;
    line-height: 0;
    height: 0 !important;
    min-height: 0 !important;
    max-height: 0 !important;
    padding: 0 !important;
    border: none !important;
  }

  #sizer .cell::before {
    content: '-';
  }
`;

// node_modules/@vaadin/a11y-base/src/disabled-mixin.js
var DisabledMixin = dedupeMixin((superclass) => class DisabledMixinClass extends superclass {
  static get properties() {
    return {
      disabled: {
        type: Boolean,
        value: false,
        observer: "_disabledChanged",
        reflectToAttribute: true,
        sync: true
      }
    };
  }
  _disabledChanged(disabled) {
    this._setAriaDisabled(disabled);
  }
  _setAriaDisabled(disabled) {
    if (disabled) {
      this.setAttribute("aria-disabled", "true");
    } else {
      this.removeAttribute("aria-disabled");
    }
  }
  click() {
    if (!this.disabled) {
      super.click();
    }
  }
});

// node_modules/@vaadin/a11y-base/src/tabindex-mixin.js
var TabindexMixin = (superclass) => class TabindexMixinClass extends DisabledMixin(superclass) {
  static get properties() {
    return {
      tabindex: {
        type: Number,
        reflectToAttribute: true,
        observer: "_tabindexChanged",
        sync: true
      },
      _lastTabIndex: {
        type: Number
      }
    };
  }
  _disabledChanged(disabled, oldDisabled) {
    super._disabledChanged(disabled, oldDisabled);
    if (this.__shouldAllowFocusWhenDisabled()) {
      return;
    }
    if (disabled) {
      if (this.tabindex !== undefined) {
        this._lastTabIndex = this.tabindex;
      }
      this.setAttribute("tabindex", "-1");
    } else if (oldDisabled) {
      if (this._lastTabIndex !== undefined) {
        this.setAttribute("tabindex", this._lastTabIndex);
      } else {
        this.tabindex = undefined;
      }
    }
  }
  _tabindexChanged(tabindex) {
    if (this.__shouldAllowFocusWhenDisabled()) {
      return;
    }
    if (this.disabled && tabindex !== -1) {
      this._lastTabIndex = tabindex;
      this.setAttribute("tabindex", "-1");
    }
  }
  focus(options) {
    if (!this.disabled || this.__shouldAllowFocusWhenDisabled()) {
      super.focus(options);
    }
  }
  __shouldAllowFocusWhenDisabled() {
    return false;
  }
};

// node_modules/@vaadin/component-base/src/browser-utils.js
var testUserAgent = (regexp) => regexp.test(navigator.userAgent);
var testPlatform = (regexp) => regexp.test(navigator.platform);
var testVendor = (regexp) => regexp.test(navigator.vendor);
var isAndroid = testUserAgent(/Android/u);
var isChrome = testUserAgent(/Chrome/u) && testVendor(/Google Inc/u);
var isFirefox = testUserAgent(/Firefox/u);
var isIPad = testPlatform(/^iPad/u) || testPlatform(/^Mac/u) && navigator.maxTouchPoints > 1;
var isIPhone = testPlatform(/^iPhone/u);
var isIOS = isIPhone || isIPad;
var isSafari = testUserAgent(/^((?!chrome|android).)*safari/iu);
var isTouch = (() => {
  try {
    document.createEvent("TouchEvent");
    return true;
  } catch (_) {
    return false;
  }
})();

// node_modules/@vaadin/component-base/src/dom-utils.js
function getClosestElement(selector, node) {
  if (!node) {
    return null;
  }
  return node.closest(selector) || getClosestElement(selector, node.getRootNode().host);
}
function isEmptyTextNode(node) {
  return node.nodeType === Node.TEXT_NODE && node.textContent.trim() === "";
}

// node_modules/@vaadin/component-base/src/slot-observer.js
class SlotObserver {
  constructor(slot, callback) {
    this.slot = slot;
    this.callback = callback;
    this._storedNodes = [];
    this._connected = false;
    this._scheduled = false;
    this._boundSchedule = () => {
      this._schedule();
    };
    this.connect();
    this._schedule();
  }
  connect() {
    this.slot.addEventListener("slotchange", this._boundSchedule);
    this._connected = true;
  }
  disconnect() {
    this.slot.removeEventListener("slotchange", this._boundSchedule);
    this._connected = false;
  }
  _schedule() {
    if (!this._scheduled) {
      this._scheduled = true;
      queueMicrotask(() => {
        this.flush();
      });
    }
  }
  flush() {
    if (!this._connected) {
      return;
    }
    this._scheduled = false;
    this._processNodes();
  }
  _processNodes() {
    const currentNodes = this.slot.assignedNodes({ flatten: true });
    let addedNodes = [];
    const removedNodes = [];
    const movedNodes = [];
    if (currentNodes.length) {
      addedNodes = currentNodes.filter((node) => !this._storedNodes.includes(node));
    }
    if (this._storedNodes.length) {
      this._storedNodes.forEach((node, index) => {
        const idx = currentNodes.indexOf(node);
        if (idx === -1) {
          removedNodes.push(node);
        } else if (idx !== index) {
          movedNodes.push(node);
        }
      });
    }
    if (addedNodes.length || removedNodes.length || movedNodes.length) {
      this.callback({ addedNodes, currentNodes, movedNodes, removedNodes });
    }
    this._storedNodes = currentNodes;
  }
}

// node_modules/@vaadin/component-base/src/unique-id-utils.js
var uniqueId = 0;
function generateUniqueId() {
  return uniqueId++;
}

// node_modules/@vaadin/component-base/src/slot-controller.js
class SlotController extends EventTarget {
  static generateId(host, prefix = "default") {
    return `${prefix}-${host.localName}-${generateUniqueId()}`;
  }
  constructor(host, slotName, tagName, config = {}) {
    super();
    const { initializer, multiple, observe, useUniqueId, uniqueIdPrefix } = config;
    this.host = host;
    this.slotName = slotName;
    this.tagName = tagName;
    this.observe = typeof observe === "boolean" ? observe : true;
    this.multiple = typeof multiple === "boolean" ? multiple : false;
    this.slotInitializer = initializer;
    if (multiple) {
      this.nodes = [];
    }
    if (useUniqueId) {
      this.defaultId = this.constructor.generateId(host, uniqueIdPrefix || slotName);
    }
  }
  hostConnected() {
    if (!this.initialized) {
      if (this.multiple) {
        this.initMultiple();
      } else {
        this.initSingle();
      }
      if (this.observe) {
        this.observeSlot();
      }
      this.initialized = true;
    }
  }
  initSingle() {
    let node = this.getSlotChild();
    if (!node) {
      node = this.attachDefaultNode();
      this.initNode(node);
    } else {
      this.node = node;
      this.initAddedNode(node);
    }
  }
  initMultiple() {
    const children = this.getSlotChildren();
    if (children.length === 0) {
      const defaultNode = this.attachDefaultNode();
      if (defaultNode) {
        this.nodes = [defaultNode];
        this.initNode(defaultNode);
      }
    } else {
      this.nodes = children;
      children.forEach((node) => {
        this.initAddedNode(node);
      });
    }
  }
  attachDefaultNode() {
    const { host, slotName, tagName } = this;
    let node = this.defaultNode;
    if (!node && tagName) {
      node = document.createElement(tagName);
      if (node instanceof Element) {
        if (slotName !== "") {
          node.setAttribute("slot", slotName);
        }
        this.defaultNode = node;
      }
    }
    if (node) {
      this.node = node;
      host.appendChild(node);
    }
    return node;
  }
  getSlotChildren() {
    const { slotName } = this;
    return Array.from(this.host.childNodes).filter((node) => {
      if (node.nodeType === Node.ELEMENT_NODE && node.hasAttribute("data-slot-ignore")) {
        return false;
      }
      return node.nodeType === Node.ELEMENT_NODE && node.slot === slotName || node.nodeType === Node.TEXT_NODE && node.textContent.trim() && slotName === "";
    });
  }
  getSlotChild() {
    return this.getSlotChildren()[0];
  }
  initNode(node) {
    const { slotInitializer } = this;
    if (slotInitializer) {
      slotInitializer(node, this.host);
    }
  }
  initCustomNode(_node) {}
  teardownNode(_node) {}
  initAddedNode(node) {
    if (node !== this.defaultNode) {
      this.initCustomNode(node);
      this.initNode(node);
    }
  }
  observeSlot() {
    const { slotName } = this;
    const selector = slotName === "" ? "slot:not([name])" : `slot[name=${slotName}]`;
    const slot = this.host.shadowRoot.querySelector(selector);
    this.__slotObserver = new SlotObserver(slot, ({ addedNodes, removedNodes }) => {
      const current = this.multiple ? this.nodes : [this.node];
      const newNodes = addedNodes.filter((node) => !isEmptyTextNode(node) && !current.includes(node) && !(node.nodeType === Node.ELEMENT_NODE && node.hasAttribute("data-slot-ignore")));
      if (removedNodes.length) {
        this.nodes = current.filter((node) => !removedNodes.includes(node));
        removedNodes.forEach((node) => {
          this.teardownNode(node);
        });
      }
      if (newNodes && newNodes.length > 0) {
        if (this.multiple) {
          if (this.defaultNode) {
            this.defaultNode.remove();
          }
          this.nodes = [...current, ...newNodes].filter((node) => node !== this.defaultNode);
          newNodes.forEach((node) => {
            this.initAddedNode(node);
          });
        } else {
          if (this.node) {
            this.node.remove();
          }
          this.node = newNodes[0];
          this.initAddedNode(this.node);
        }
      }
    });
  }
}

// node_modules/@vaadin/component-base/src/tooltip-controller.js
class TooltipController extends SlotController {
  constructor(host) {
    super(host, "tooltip");
    this.setTarget(host);
    this.__onContentChange = this.__onContentChange.bind(this);
  }
  initCustomNode(tooltipNode) {
    tooltipNode.target = this.target;
    if (this.ariaTarget !== undefined) {
      tooltipNode.ariaTarget = this.ariaTarget;
    }
    if (this.context !== undefined) {
      tooltipNode.context = this.context;
    }
    if (this.manual !== undefined) {
      tooltipNode.manual = this.manual;
    }
    if (this.opened !== undefined) {
      tooltipNode.opened = this.opened;
    }
    if (this.position !== undefined) {
      tooltipNode._position = this.position;
    }
    if (this.shouldShow !== undefined) {
      tooltipNode.shouldShow = this.shouldShow;
    }
    if (!this.manual) {
      this.host.setAttribute("has-tooltip", "");
    }
    this.__notifyChange(tooltipNode);
    tooltipNode.addEventListener("content-changed", this.__onContentChange);
  }
  teardownNode(tooltipNode) {
    if (!this.manual) {
      this.host.removeAttribute("has-tooltip");
    }
    tooltipNode.removeEventListener("content-changed", this.__onContentChange);
    this.__notifyChange(null);
  }
  setAriaTarget(ariaTarget) {
    this.ariaTarget = ariaTarget;
    const tooltipNode = this.node;
    if (tooltipNode) {
      tooltipNode.ariaTarget = ariaTarget;
    }
  }
  setContext(context) {
    this.context = context;
    const tooltipNode = this.node;
    if (tooltipNode) {
      tooltipNode.context = context;
    }
  }
  setManual(manual) {
    this.manual = manual;
    const tooltipNode = this.node;
    if (tooltipNode) {
      tooltipNode.manual = manual;
    }
  }
  setOpened(opened) {
    this.opened = opened;
    const tooltipNode = this.node;
    if (tooltipNode) {
      tooltipNode.opened = opened;
    }
  }
  setPosition(position) {
    this.position = position;
    const tooltipNode = this.node;
    if (tooltipNode) {
      tooltipNode._position = position;
    }
  }
  setShouldShow(shouldShow) {
    this.shouldShow = shouldShow;
    const tooltipNode = this.node;
    if (tooltipNode) {
      tooltipNode.shouldShow = shouldShow;
    }
  }
  setTarget(target) {
    this.target = target;
    const tooltipNode = this.node;
    if (tooltipNode) {
      tooltipNode.target = target;
    }
  }
  __onContentChange(event) {
    this.__notifyChange(event.target);
  }
  __notifyChange(node) {
    this.dispatchEvent(new CustomEvent("tooltip-changed", { detail: { node } }));
  }
}

// node_modules/@vaadin/component-base/src/iron-list-core.js
var IOS = navigator.userAgent.match(/iP(?:hone|ad;(?: U;)? CPU) OS (\d+)/u);
var IOS_TOUCH_SCROLLING = IOS && IOS[1] >= 8;
var DEFAULT_PHYSICAL_COUNT = 3;
var ironList = {
  _ratio: 0.5,
  _scrollerPaddingTop: 0,
  _scrollPosition: 0,
  _physicalSize: 0,
  _physicalAverage: 0,
  _physicalAverageCount: 0,
  _physicalTop: 0,
  _virtualCount: 0,
  _estScrollHeight: 0,
  _scrollHeight: 0,
  _viewportHeight: 0,
  _viewportWidth: 0,
  _physicalItems: null,
  _physicalSizes: null,
  _firstVisibleIndexVal: null,
  _lastVisibleIndexVal: null,
  _maxPages: 2,
  _templateCost: 0,
  get _physicalBottom() {
    return this._physicalTop + this._physicalSize;
  },
  get _scrollBottom() {
    return this._scrollPosition + this._viewportHeight;
  },
  get _virtualEnd() {
    return this._virtualStart + this._physicalCount - 1;
  },
  get _hiddenContentSize() {
    return this._physicalSize - this._viewportHeight;
  },
  get _maxScrollTop() {
    return this._estScrollHeight - this._viewportHeight + this._scrollOffset;
  },
  get _maxVirtualStart() {
    const virtualCount = this._virtualCount;
    return Math.max(0, virtualCount - this._physicalCount);
  },
  get _virtualStart() {
    return this._virtualStartVal || 0;
  },
  set _virtualStart(val) {
    val = this._clamp(val, 0, this._maxVirtualStart);
    this._virtualStartVal = val;
  },
  get _physicalStart() {
    return this._physicalStartVal || 0;
  },
  set _physicalStart(val) {
    val %= this._physicalCount;
    if (val < 0) {
      val = this._physicalCount + val;
    }
    this._physicalStartVal = val;
  },
  get _physicalEnd() {
    return (this._physicalStart + this._physicalCount - 1) % this._physicalCount;
  },
  get _physicalCount() {
    return this._physicalCountVal || 0;
  },
  set _physicalCount(val) {
    this._physicalCountVal = val;
  },
  get _optPhysicalSize() {
    return this._viewportHeight === 0 ? Infinity : this._viewportHeight * this._maxPages;
  },
  get _isVisible() {
    return Boolean(this.offsetWidth || this.offsetHeight);
  },
  get firstVisibleIndex() {
    let idx = this._firstVisibleIndexVal;
    if (idx == null) {
      let physicalOffset = this._physicalTop + this._scrollOffset;
      idx = this._iterateItems((pidx, vidx) => {
        physicalOffset += this._getPhysicalSizeIncrement(pidx);
        if (physicalOffset > this._scrollPosition) {
          return vidx;
        }
      }) || 0;
      this._firstVisibleIndexVal = idx;
    }
    return idx;
  },
  get lastVisibleIndex() {
    let idx = this._lastVisibleIndexVal;
    if (idx == null) {
      let physicalOffset = this._physicalTop + this._scrollOffset;
      this._iterateItems((pidx, vidx) => {
        if (physicalOffset < this._scrollBottom) {
          idx = vidx;
        }
        physicalOffset += this._getPhysicalSizeIncrement(pidx);
      });
      this._lastVisibleIndexVal = idx;
    }
    return idx;
  },
  get _scrollOffset() {
    return this._scrollerPaddingTop + this.scrollOffset;
  },
  _scrollHandler() {
    const scrollTop = Math.max(0, Math.min(this._maxScrollTop, this._scrollTop));
    let delta = scrollTop - this._scrollPosition;
    const isScrollingDown = delta >= 0;
    this._scrollPosition = scrollTop;
    this._firstVisibleIndexVal = null;
    this._lastVisibleIndexVal = null;
    if (Math.abs(delta) > this._physicalSize && this._physicalSize > 0) {
      delta -= this._scrollOffset;
      const idxAdjustment = Math.round(delta / this._physicalAverage);
      this._virtualStart += idxAdjustment;
      this._physicalStart += idxAdjustment;
      this._physicalTop = Math.min(Math.floor(this._virtualStart) * this._physicalAverage, this._scrollPosition);
      this._update();
    } else if (this._physicalCount > 0) {
      const reusables = this._getReusables(isScrollingDown);
      if (isScrollingDown) {
        this._physicalTop = reusables.physicalTop;
        this._virtualStart += reusables.indexes.length;
        this._physicalStart += reusables.indexes.length;
      } else {
        this._virtualStart -= reusables.indexes.length;
        this._physicalStart -= reusables.indexes.length;
      }
      this._update(reusables.indexes, isScrollingDown ? null : reusables.indexes);
      this._debounce("_increasePoolIfNeeded", this._increasePoolIfNeeded.bind(this, 0), microTask);
    }
  },
  _getReusables(fromTop) {
    let ith, offsetContent, physicalItemHeight;
    const idxs = [];
    const protectedOffsetContent = this._hiddenContentSize * this._ratio;
    const virtualStart = this._virtualStart;
    const virtualEnd = this._virtualEnd;
    const physicalCount = this._physicalCount;
    let top = this._physicalTop + this._scrollOffset;
    const bottom = this._physicalBottom + this._scrollOffset;
    const scrollTop = this._scrollPosition;
    const scrollBottom = this._scrollBottom;
    if (fromTop) {
      ith = this._physicalStart;
      offsetContent = scrollTop - top;
    } else {
      ith = this._physicalEnd;
      offsetContent = bottom - scrollBottom;
    }
    while (true) {
      physicalItemHeight = this._getPhysicalSizeIncrement(ith);
      offsetContent -= physicalItemHeight;
      if (idxs.length >= physicalCount || offsetContent <= protectedOffsetContent) {
        break;
      }
      if (fromTop) {
        if (virtualEnd + idxs.length + 1 >= this._virtualCount) {
          break;
        }
        if (top + physicalItemHeight >= scrollTop - this._scrollOffset) {
          break;
        }
        idxs.push(ith);
        top += physicalItemHeight;
        ith = (ith + 1) % physicalCount;
      } else {
        if (virtualStart - idxs.length <= 0) {
          break;
        }
        if (top + this._physicalSize - physicalItemHeight <= scrollBottom) {
          break;
        }
        idxs.push(ith);
        top -= physicalItemHeight;
        ith = ith === 0 ? physicalCount - 1 : ith - 1;
      }
    }
    return { indexes: idxs, physicalTop: top - this._scrollOffset };
  },
  _update(itemSet, movingUp) {
    if (itemSet && itemSet.length === 0 || this._physicalCount === 0) {
      return;
    }
    this._assignModels(itemSet);
    this._updateMetrics(itemSet);
    if (movingUp) {
      while (movingUp.length) {
        const idx = movingUp.pop();
        this._physicalTop -= this._getPhysicalSizeIncrement(idx);
      }
    }
    this._positionItems();
    this._updateScrollerSize();
  },
  _isClientFull() {
    return this._scrollBottom !== 0 && this._physicalBottom - 1 >= this._scrollBottom && this._physicalTop <= this._scrollPosition;
  },
  _increasePoolIfNeeded(count) {
    const nextPhysicalCount = this._clamp(this._physicalCount + count, DEFAULT_PHYSICAL_COUNT, this._virtualCount - this._virtualStart);
    const delta = nextPhysicalCount - this._physicalCount;
    let nextIncrease = Math.round(this._physicalCount * 0.5);
    if (delta < 0) {
      return;
    }
    if (delta > 0) {
      const ts = window.performance.now();
      [].push.apply(this._physicalItems, this._createPool(delta));
      for (let i = 0;i < delta; i++) {
        this._physicalSizes.push(0);
      }
      this._physicalCount += delta;
      if (this._physicalStart > this._physicalEnd && this._isIndexRendered(this._focusedVirtualIndex) && this._getPhysicalIndex(this._focusedVirtualIndex) < this._physicalEnd) {
        this._physicalStart += delta;
      }
      this._update();
      this._templateCost = (window.performance.now() - ts) / delta;
      nextIncrease = Math.round(this._physicalCount * 0.5);
    }
    if (this._virtualEnd >= this._virtualCount - 1 || nextIncrease === 0) {} else if (!this._isClientFull()) {
      this._debounce("_increasePoolIfNeeded", this._increasePoolIfNeeded.bind(this, nextIncrease), microTask);
    } else if (this._physicalSize < this._optPhysicalSize) {
      this._debounce("_increasePoolIfNeeded", this._increasePoolIfNeeded.bind(this, this._clamp(Math.round(50 / this._templateCost), 1, nextIncrease)), idlePeriod);
    }
  },
  _render() {
    if (!this.isAttached || !this._isVisible) {
      return;
    }
    if (this._physicalCount !== 0) {
      const reusables = this._getReusables(true);
      this._physicalTop = reusables.physicalTop;
      this._virtualStart += reusables.indexes.length;
      this._physicalStart += reusables.indexes.length;
      this._update(reusables.indexes);
      this._update();
      this._increasePoolIfNeeded(0);
    } else if (this._virtualCount > 0) {
      this.updateViewportBoundaries();
      this._increasePoolIfNeeded(DEFAULT_PHYSICAL_COUNT);
    }
  },
  _itemsChanged(change) {
    if (change.path === "items") {
      this._virtualStart = 0;
      this._physicalTop = 0;
      this._virtualCount = this.items ? this.items.length : 0;
      this._physicalIndexForKey = {};
      this._firstVisibleIndexVal = null;
      this._lastVisibleIndexVal = null;
      if (!this._physicalItems) {
        this._physicalItems = [];
      }
      if (!this._physicalSizes) {
        this._physicalSizes = [];
      }
      this._physicalStart = 0;
      if (this._scrollTop > this._scrollOffset) {
        this._resetScrollPosition(0);
      }
      this._debounce("_render", this._render, animationFrame);
    }
  },
  _iterateItems(fn, itemSet) {
    let pidx, vidx, rtn, i;
    if (arguments.length === 2 && itemSet) {
      for (i = 0;i < itemSet.length; i++) {
        pidx = itemSet[i];
        vidx = this._computeVidx(pidx);
        if ((rtn = fn.call(this, pidx, vidx)) != null) {
          return rtn;
        }
      }
    } else {
      pidx = this._physicalStart;
      vidx = this._virtualStart;
      for (;pidx < this._physicalCount; pidx++, vidx++) {
        if ((rtn = fn.call(this, pidx, vidx)) != null) {
          return rtn;
        }
      }
      for (pidx = 0;pidx < this._physicalStart; pidx++, vidx++) {
        if ((rtn = fn.call(this, pidx, vidx)) != null) {
          return rtn;
        }
      }
    }
  },
  _computeVidx(pidx) {
    if (pidx >= this._physicalStart) {
      return this._virtualStart + (pidx - this._physicalStart);
    }
    return this._virtualStart + (this._physicalCount - this._physicalStart) + pidx;
  },
  _positionItems() {
    this._adjustScrollPosition();
    let y = this._physicalTop;
    this._iterateItems((pidx) => {
      this.translate3d(0, `${y}px`, 0, this._physicalItems[pidx]);
      y += this._physicalSizes[pidx];
    });
  },
  _getPhysicalSizeIncrement(pidx) {
    return this._physicalSizes[pidx];
  },
  _adjustScrollPosition() {
    const deltaHeight = this._virtualStart === 0 ? this._physicalTop : Math.min(this._scrollPosition + this._physicalTop, 0);
    if (deltaHeight !== 0) {
      this._physicalTop -= deltaHeight;
      const scrollTop = this._scrollPosition;
      if (!IOS_TOUCH_SCROLLING && scrollTop > 0) {
        this._resetScrollPosition(scrollTop - deltaHeight);
      }
    }
  },
  _resetScrollPosition(pos) {
    if (this.scrollTarget && pos >= 0) {
      this._scrollTop = pos;
      this._scrollPosition = this._scrollTop;
    }
  },
  _updateScrollerSize(forceUpdate) {
    const estScrollHeight = this._physicalBottom + Math.max(this._virtualCount - this._physicalCount - this._virtualStart, 0) * this._physicalAverage;
    this._estScrollHeight = estScrollHeight;
    if (forceUpdate || this._scrollHeight === 0 || this._scrollPosition >= estScrollHeight - this._physicalSize || Math.abs(estScrollHeight - this._scrollHeight) >= this._viewportHeight) {
      this.$.items.style.height = `${estScrollHeight}px`;
      this._scrollHeight = estScrollHeight;
    }
  },
  scrollToIndex(idx) {
    if (typeof idx !== "number" || idx < 0 || idx > this.items.length - 1) {
      return;
    }
    flush();
    if (this._physicalCount === 0) {
      return;
    }
    idx = this._clamp(idx, 0, this._virtualCount - 1);
    if (!this._isIndexRendered(idx) || idx >= this._maxVirtualStart) {
      this._virtualStart = idx - 1;
    }
    this._assignModels();
    this._updateMetrics();
    this._physicalTop = this._virtualStart * this._physicalAverage;
    let currentTopItem = this._physicalStart;
    let currentVirtualItem = this._virtualStart;
    let targetOffsetTop = 0;
    const hiddenContentSize = this._hiddenContentSize;
    while (currentVirtualItem < idx && targetOffsetTop <= hiddenContentSize) {
      targetOffsetTop += this._getPhysicalSizeIncrement(currentTopItem);
      currentTopItem = (currentTopItem + 1) % this._physicalCount;
      currentVirtualItem += 1;
    }
    this._updateScrollerSize(true);
    this._positionItems();
    this._resetScrollPosition(this._physicalTop + this._scrollOffset + targetOffsetTop);
    this._increasePoolIfNeeded(0);
    this._firstVisibleIndexVal = null;
    this._lastVisibleIndexVal = null;
  },
  _resetAverage() {
    this._physicalAverage = 0;
    this._physicalAverageCount = 0;
  },
  _resizeHandler() {
    this._debounce("_render", () => {
      this._firstVisibleIndexVal = null;
      this._lastVisibleIndexVal = null;
      if (this._isVisible) {
        this.updateViewportBoundaries();
        this.toggleScrollListener(true);
        this._resetAverage();
        this._render();
      } else {
        this.toggleScrollListener(false);
      }
    }, animationFrame);
  },
  _isIndexRendered(idx) {
    return idx >= this._virtualStart && idx <= this._virtualEnd;
  },
  _getPhysicalIndex(vidx) {
    return (this._physicalStart + (vidx - this._virtualStart)) % this._physicalCount;
  },
  _clamp(v, min, max) {
    return Math.min(max, Math.max(min, v));
  },
  _debounce(name, cb, asyncModule) {
    if (!this._debouncers) {
      this._debouncers = {};
    }
    this._debouncers[name] = Debouncer.debounce(this._debouncers[name], asyncModule, cb.bind(this));
    enqueueDebouncer(this._debouncers[name]);
  }
};

// node_modules/@vaadin/component-base/src/virtualizer-iron-list-adapter.js
var MAX_VIRTUAL_COUNT = 1e5;
var OFFSET_ADJUST_MIN_THRESHOLD = 1000;

class IronListAdapter {
  constructor({
    createElements,
    updateElement,
    scrollTarget,
    scrollContainer,
    reorderElements,
    elementsContainer,
    __disableHeightPlaceholder
  }) {
    this.isAttached = true;
    this._vidxOffset = 0;
    this.createElements = createElements;
    this.updateElement = updateElement;
    this.scrollTarget = scrollTarget;
    this.scrollContainer = scrollContainer;
    this.reorderElements = reorderElements;
    this.elementsContainer = elementsContainer || scrollContainer;
    this.__disableHeightPlaceholder = __disableHeightPlaceholder ?? false;
    this._maxPages = 1.3;
    this.__placeholderHeight = 200;
    this.__elementHeightQueue = Array(10);
    this.timeouts = {
      SCROLL_REORDER: 500,
      PREVENT_OVERSCROLL: 500,
      FIX_INVALID_ITEM_POSITIONING: 100
    };
    this.__resizeObserver = new ResizeObserver(() => this._resizeHandler());
    if (getComputedStyle(this.scrollTarget).overflow === "visible") {
      this.scrollTarget.style.overflow = "auto";
    }
    if (getComputedStyle(this.scrollContainer).position === "static") {
      this.scrollContainer.style.position = "relative";
    }
    this.__resizeObserver.observe(this.scrollTarget);
    this.scrollTarget.addEventListener("scroll", () => this._scrollHandler());
    const attachObserver = new ResizeObserver(([{ contentRect }]) => {
      const isHidden = contentRect.width === 0 && contentRect.height === 0;
      if (!isHidden && this.__scrollTargetHidden && this.scrollTarget.scrollTop !== this._scrollPosition) {
        this.scrollTarget.scrollTop = this._scrollPosition;
      }
      this.__scrollTargetHidden = isHidden;
    });
    attachObserver.observe(this.scrollTarget);
    this._scrollLineHeight = this._getScrollLineHeight();
    this.scrollTarget.addEventListener("virtualizer-element-focused", (e) => this.__onElementFocused(e));
    this.elementsContainer.addEventListener("focusin", () => {
      this.scrollTarget.dispatchEvent(new CustomEvent("virtualizer-element-focused", { detail: { element: this.__getFocusedElement() } }));
    });
    if (this.reorderElements) {
      this.scrollTarget.addEventListener("mousedown", () => {
        this.__mouseDown = true;
      });
      this.scrollTarget.addEventListener("mouseup", () => {
        this.__mouseDown = false;
        if (this.__pendingReorder) {
          this.__reorderElements();
        }
      });
    }
  }
  get scrollOffset() {
    return 0;
  }
  get adjustedFirstVisibleIndex() {
    return this.firstVisibleIndex + this._vidxOffset;
  }
  get adjustedLastVisibleIndex() {
    return this.lastVisibleIndex + this._vidxOffset;
  }
  get _maxVirtualIndexOffset() {
    return this.size - this._virtualCount;
  }
  __hasPlaceholders() {
    return this.__getVisibleElements().some((el) => el.__virtualizerPlaceholder);
  }
  scrollToIndex(index) {
    if (typeof index !== "number" || isNaN(index) || this.size === 0 || !this.scrollTarget.offsetHeight) {
      return;
    }
    delete this.__pendingScrollToIndex;
    if (this._physicalCount <= 3) {
      this.flush();
    }
    index = this._clamp(index, 0, this.size - 1);
    const visibleElementCount = this.__getVisibleElements().length;
    let targetVirtualIndex = Math.floor(index / this.size * this._virtualCount);
    if (this._virtualCount - targetVirtualIndex < visibleElementCount) {
      targetVirtualIndex = this._virtualCount - (this.size - index);
      this._vidxOffset = this._maxVirtualIndexOffset;
    } else if (targetVirtualIndex < visibleElementCount) {
      if (index < OFFSET_ADJUST_MIN_THRESHOLD) {
        targetVirtualIndex = index;
        this._vidxOffset = 0;
      } else {
        targetVirtualIndex = OFFSET_ADJUST_MIN_THRESHOLD;
        this._vidxOffset = index - targetVirtualIndex;
      }
    } else {
      this._vidxOffset = index - targetVirtualIndex;
    }
    this.__skipNextVirtualIndexAdjust = true;
    super.scrollToIndex(targetVirtualIndex);
    if (this.adjustedFirstVisibleIndex !== index && this._scrollTop < this._maxScrollTop && !this.grid) {
      this._scrollTop -= this.__getIndexScrollOffset(index) || 0;
    }
    this._scrollHandler();
    if (this.__hasPlaceholders()) {
      this.__pendingScrollToIndex = index;
    }
  }
  flush() {
    if (this.scrollTarget.offsetHeight === 0) {
      return;
    }
    this._resizeHandler();
    flush();
    this._scrollHandler();
    if (this.__fixInvalidItemPositioningDebouncer) {
      this.__fixInvalidItemPositioningDebouncer.flush();
    }
    if (this.__scrollReorderDebouncer) {
      this.__scrollReorderDebouncer.flush();
    }
    if (this.__debouncerWheelAnimationFrame) {
      this.__debouncerWheelAnimationFrame.flush();
    }
  }
  hostConnected() {
    if (this.scrollTarget.offsetParent && this.scrollTarget.scrollTop !== this._scrollPosition) {
      this.scrollTarget.scrollTop = this._scrollPosition;
    }
  }
  update(startIndex = 0, endIndex = this.size - 1) {
    const updatedElements = [];
    this.__getVisibleElements().forEach((el) => {
      if (el.__virtualIndex >= startIndex && el.__virtualIndex <= endIndex) {
        this.__updateElement(el, el.__virtualIndex, true);
        updatedElements.push(el);
      }
    });
    this.__afterElementsUpdated(updatedElements);
  }
  _updateMetrics(itemSet) {
    flush();
    let newPhysicalSize = 0;
    let oldPhysicalSize = 0;
    const prevAvgCount = this._physicalAverageCount;
    const prevPhysicalAvg = this._physicalAverage;
    this._iterateItems((pidx, vidx) => {
      oldPhysicalSize += this._physicalSizes[pidx];
      const elementOldPhysicalSize = this._physicalSizes[pidx];
      this._physicalSizes[pidx] = Math.ceil(this.__getBorderBoxHeight(this._physicalItems[pidx]));
      if (this._physicalSizes[pidx] !== elementOldPhysicalSize) {
        this.__resizeObserver.unobserve(this._physicalItems[pidx]);
        this.__resizeObserver.observe(this._physicalItems[pidx], { box: "border-box" });
      }
      newPhysicalSize += this._physicalSizes[pidx];
      this._physicalAverageCount += this._physicalSizes[pidx] ? 1 : 0;
    }, itemSet);
    this._physicalSize = this._physicalSize + newPhysicalSize - oldPhysicalSize;
    if (this._physicalAverageCount !== prevAvgCount) {
      this._physicalAverage = Math.round((prevPhysicalAvg * prevAvgCount + newPhysicalSize) / this._physicalAverageCount);
    }
  }
  __getBorderBoxHeight(el) {
    const style = getComputedStyle(el);
    const itemHeight = parseFloat(style.height) || 0;
    if (style.boxSizing === "border-box") {
      return itemHeight;
    }
    const paddingBottom = parseFloat(style.paddingBottom) || 0;
    const paddingTop = parseFloat(style.paddingTop) || 0;
    const borderBottomWidth = parseFloat(style.borderBottomWidth) || 0;
    const borderTopWidth = parseFloat(style.borderTopWidth) || 0;
    return itemHeight + paddingBottom + paddingTop + borderBottomWidth + borderTopWidth;
  }
  __updateElement(el, index, forceSameIndexUpdates) {
    if (el.__virtualizerPlaceholder) {
      el.style.paddingTop = "";
      el.style.opacity = "";
      el.__virtualizerPlaceholder = false;
    }
    if (!this.__preventElementUpdates && (el.__lastUpdatedIndex !== index || forceSameIndexUpdates)) {
      this.updateElement(el, index);
      el.__lastUpdatedIndex = index;
    }
  }
  __afterElementsUpdated(updatedElements) {
    if (!this.__disableHeightPlaceholder) {
      updatedElements.forEach((el) => {
        const elementHeight = el.offsetHeight;
        if (elementHeight === 0) {
          el.style.paddingTop = `${this.__placeholderHeight}px`;
          el.style.opacity = "0";
          el.__virtualizerPlaceholder = true;
          this.__placeholderClearDebouncer = Debouncer.debounce(this.__placeholderClearDebouncer, animationFrame, () => this._resizeHandler());
        } else {
          this.__elementHeightQueue.push(elementHeight);
          this.__elementHeightQueue.shift();
          const filteredHeights = this.__elementHeightQueue.filter((h) => h !== undefined);
          this.__placeholderHeight = Math.round(filteredHeights.reduce((a, b) => a + b, 0) / filteredHeights.length);
        }
      });
    }
    if (this.__pendingScrollToIndex !== undefined && !this.__hasPlaceholders()) {
      this.scrollToIndex(this.__pendingScrollToIndex);
    }
  }
  __getIndexScrollOffset(index) {
    const element = this.__getVisibleElements().find((el) => el.__virtualIndex === index);
    return element ? this.scrollTarget.getBoundingClientRect().top - element.getBoundingClientRect().top : undefined;
  }
  get size() {
    return this.__size;
  }
  set size(size) {
    if (size === this.size) {
      return;
    }
    if (this.__fixInvalidItemPositioningDebouncer) {
      this.__fixInvalidItemPositioningDebouncer.cancel();
    }
    if (this._debouncers && this._debouncers._increasePoolIfNeeded) {
      this._debouncers._increasePoolIfNeeded.cancel();
    }
    this.__preventElementUpdates = true;
    let fvi;
    let fviOffsetBefore;
    if (size > 0) {
      fvi = this.adjustedFirstVisibleIndex;
      fviOffsetBefore = this.__getIndexScrollOffset(fvi);
    }
    this.__size = size;
    this._itemsChanged({
      path: "items"
    });
    flush();
    if (size > 0) {
      fvi = Math.min(fvi, size - 1);
      this.scrollToIndex(fvi);
      const fviOffsetAfter = this.__getIndexScrollOffset(fvi);
      if (fviOffsetBefore !== undefined && fviOffsetAfter !== undefined) {
        this._scrollTop += fviOffsetBefore - fviOffsetAfter;
      }
    }
    this.__preventElementUpdates = false;
    if (!this._isVisible) {
      this._assignModels();
    }
    if (!this.elementsContainer.children.length) {
      requestAnimationFrame(() => this._resizeHandler());
    }
    this._resizeHandler();
    flush();
    this._debounce("_update", this._update, microTask);
  }
  get _scrollTop() {
    return this.scrollTarget.scrollTop;
  }
  set _scrollTop(top) {
    this.scrollTarget.scrollTop = top;
  }
  get items() {
    return {
      length: Math.min(this.size, MAX_VIRTUAL_COUNT)
    };
  }
  get offsetHeight() {
    return this.scrollTarget.offsetHeight;
  }
  get $() {
    return {
      items: this.scrollContainer
    };
  }
  updateViewportBoundaries() {
    const styles = window.getComputedStyle(this.scrollTarget);
    this._scrollerPaddingTop = this.scrollTarget === this ? 0 : parseInt(styles["padding-top"], 10);
    this._isRTL = Boolean(styles.direction === "rtl");
    this._viewportWidth = this.elementsContainer.offsetWidth;
    this._viewportHeight = this.scrollTarget.offsetHeight;
    this._scrollPageHeight = this._viewportHeight - this._scrollLineHeight;
    if (this.grid) {
      this._updateGridMetrics();
    }
  }
  setAttribute() {}
  _createPool(size) {
    const physicalItems = this.createElements(size);
    const fragment = document.createDocumentFragment();
    physicalItems.forEach((el) => {
      el.style.position = "absolute";
      fragment.appendChild(el);
      this.__resizeObserver.observe(el, { box: "border-box" });
    });
    this.elementsContainer.appendChild(fragment);
    return physicalItems;
  }
  _assignModels(itemSet) {
    const updatedElements = [];
    this._iterateItems((pidx, vidx) => {
      const el = this._physicalItems[pidx];
      el.hidden = vidx >= this.size;
      if (!el.hidden) {
        el.__virtualIndex = vidx + (this._vidxOffset || 0);
        this.__updateElement(el, el.__virtualIndex);
        updatedElements.push(el);
      } else {
        delete el.__lastUpdatedIndex;
      }
    }, itemSet);
    this.__afterElementsUpdated(updatedElements);
  }
  _isClientFull() {
    setTimeout(() => {
      this.__clientFull = true;
    });
    return this.__clientFull || super._isClientFull();
  }
  translate3d(_x, y, _z, el) {
    el.style.transform = `translateY(${y})`;
  }
  toggleScrollListener() {}
  __getFocusedElement(visibleElements = this.__getVisibleElements()) {
    return visibleElements.find((element) => element.contains(this.elementsContainer.getRootNode().activeElement) || element.contains(this.scrollTarget.getRootNode().activeElement));
  }
  __nextFocusableSiblingMissing(focusedElement, visibleElements) {
    return visibleElements.indexOf(focusedElement) === visibleElements.length - 1 && this.size > focusedElement.__virtualIndex + 1;
  }
  __previousFocusableSiblingMissing(focusedElement, visibleElements) {
    return visibleElements.indexOf(focusedElement) === 0 && focusedElement.__virtualIndex > 0;
  }
  __onElementFocused(e) {
    if (!this.reorderElements) {
      return;
    }
    const focusedElement = e.detail.element;
    if (!focusedElement) {
      return;
    }
    const visibleElements = this.__getVisibleElements();
    if (this.__previousFocusableSiblingMissing(focusedElement, visibleElements) || this.__nextFocusableSiblingMissing(focusedElement, visibleElements)) {
      this.flush();
    }
    const reorderedVisibleElements = this.__getVisibleElements();
    if (this.__nextFocusableSiblingMissing(focusedElement, reorderedVisibleElements)) {
      this._scrollTop += Math.ceil(focusedElement.getBoundingClientRect().bottom) - Math.floor(this.scrollTarget.getBoundingClientRect().bottom - 1);
      this.flush();
    } else if (this.__previousFocusableSiblingMissing(focusedElement, reorderedVisibleElements)) {
      this._scrollTop -= Math.ceil(this.scrollTarget.getBoundingClientRect().top + 1) - Math.floor(focusedElement.getBoundingClientRect().top);
      this.flush();
    }
  }
  _scrollHandler() {
    if (this.scrollTarget.offsetHeight === 0) {
      return;
    }
    this._adjustVirtualIndexOffset(this._scrollTop - this._scrollPosition);
    const delta = this._scrollTop - this._scrollPosition;
    super._scrollHandler();
    if (this._physicalCount !== 0) {
      const isScrollingDown = delta >= 0;
      const reusables = this._getReusables(!isScrollingDown);
      if (reusables.indexes.length) {
        this._physicalTop = reusables.physicalTop;
        if (isScrollingDown) {
          this._virtualStart -= reusables.indexes.length;
          this._physicalStart -= reusables.indexes.length;
        } else {
          this._virtualStart += reusables.indexes.length;
          this._physicalStart += reusables.indexes.length;
        }
        this._resizeHandler();
      }
    }
    if (delta) {
      this.__fixInvalidItemPositioningDebouncer = Debouncer.debounce(this.__fixInvalidItemPositioningDebouncer, timeOut.after(this.timeouts.FIX_INVALID_ITEM_POSITIONING), () => this.__fixInvalidItemPositioning());
      if (!this.__overscrollDebouncer?.isActive()) {
        this.scrollTarget.style.overscrollBehavior = "none";
      }
      this.__overscrollDebouncer = Debouncer.debounce(this.__overscrollDebouncer, timeOut.after(this.timeouts.PREVENT_OVERSCROLL), () => {
        this.scrollTarget.style.overscrollBehavior = null;
      });
    }
    if (this.reorderElements) {
      this.__scrollReorderDebouncer = Debouncer.debounce(this.__scrollReorderDebouncer, timeOut.after(this.timeouts.SCROLL_REORDER), () => this.__reorderElements());
    }
    if (this._scrollPosition === 0 && this.firstVisibleIndex !== 0 && Math.abs(delta) > 0) {
      this.scrollToIndex(0);
    }
  }
  _resizeHandler() {
    super._resizeHandler();
    const lastIndexVisible = this.adjustedLastVisibleIndex === this.size - 1;
    const emptySpace = this._physicalTop - this._scrollPosition;
    if (lastIndexVisible && emptySpace > 0) {
      const idxAdjustment = Math.ceil(emptySpace / this._physicalAverage);
      this._virtualStart = Math.max(0, this._virtualStart - idxAdjustment);
      this._physicalStart = Math.max(0, this._physicalStart - idxAdjustment);
      super.scrollToIndex(this._virtualCount - 1);
      this.scrollTarget.scrollTop = this.scrollTarget.scrollHeight - this.scrollTarget.clientHeight;
    }
  }
  __fixInvalidItemPositioning() {
    if (!this.scrollTarget.isConnected) {
      return;
    }
    const physicalTopBelowTop = this._physicalTop > this._scrollTop;
    const physicalBottomAboveBottom = this._physicalBottom < this._scrollBottom;
    const firstIndexVisible = this.adjustedFirstVisibleIndex === 0;
    const lastIndexVisible = this.adjustedLastVisibleIndex === this.size - 1;
    if (physicalTopBelowTop && !firstIndexVisible || physicalBottomAboveBottom && !lastIndexVisible) {
      const isScrollingDown = physicalBottomAboveBottom;
      const originalRatio = this._ratio;
      this._ratio = 0;
      this._scrollPosition = this._scrollTop + (isScrollingDown ? -1 : 1);
      this._scrollHandler();
      this._ratio = originalRatio;
    }
  }
  _increasePoolIfNeeded(count) {
    if (this._physicalCount > 2 && this._physicalAverage > 0 && count > 0) {
      const totalItemCount = Math.ceil(this._optPhysicalSize / this._physicalAverage);
      const missingItemCount = totalItemCount - this._physicalCount;
      super._increasePoolIfNeeded(Math.max(count, Math.min(100, missingItemCount)));
    } else {
      super._increasePoolIfNeeded(count);
    }
  }
  get _optPhysicalSize() {
    const optPhysicalSize = super._optPhysicalSize;
    if (optPhysicalSize <= 0 || this.__hasPlaceholders()) {
      return optPhysicalSize;
    }
    return optPhysicalSize + this.__getItemHeightBuffer();
  }
  __getItemHeightBuffer() {
    if (this._physicalCount === 0) {
      return 0;
    }
    const bufferZoneHeight = Math.ceil(this._viewportHeight * (this._maxPages - 1) / 2);
    const maxItemHeight = Math.max(...this._physicalSizes);
    if (maxItemHeight > Math.min(...this._physicalSizes)) {
      return Math.max(0, maxItemHeight - bufferZoneHeight);
    }
    return 0;
  }
  _getScrollLineHeight() {
    const el = document.createElement("div");
    el.style.fontSize = "initial";
    el.style.display = "none";
    document.body.appendChild(el);
    const fontSize = window.getComputedStyle(el).fontSize;
    document.body.removeChild(el);
    return fontSize ? window.parseInt(fontSize) : undefined;
  }
  __getVisibleElements() {
    return Array.from(this.elementsContainer.children).filter((element) => !element.hidden);
  }
  __reorderElements() {
    if (this.__mouseDown) {
      this.__pendingReorder = true;
      return;
    }
    this.__pendingReorder = false;
    const adjustedVirtualStart = this._virtualStart + (this._vidxOffset || 0);
    const visibleElements = this.__getVisibleElements();
    const targetElement = this.__getFocusedElement(visibleElements) || visibleElements[0];
    if (!targetElement) {
      return;
    }
    const targetPhysicalIndex = targetElement.__virtualIndex - adjustedVirtualStart;
    const delta = visibleElements.indexOf(targetElement) - targetPhysicalIndex;
    if (delta > 0) {
      for (let i = 0;i < delta; i++) {
        this.elementsContainer.appendChild(visibleElements[i]);
      }
    } else if (delta < 0) {
      for (let i = visibleElements.length + delta;i < visibleElements.length; i++) {
        this.elementsContainer.insertBefore(visibleElements[i], visibleElements[0]);
      }
    }
    if (isSafari) {
      const { transform } = this.scrollTarget.style;
      this.scrollTarget.style.transform = "translateZ(0)";
      setTimeout(() => {
        this.scrollTarget.style.transform = transform;
      });
    }
  }
  _adjustVirtualIndexOffset(delta) {
    const maxOffset = this._maxVirtualIndexOffset;
    if (this._virtualCount >= this.size) {
      this._vidxOffset = 0;
    } else if (this.__skipNextVirtualIndexAdjust) {
      this.__skipNextVirtualIndexAdjust = false;
    } else if (Math.abs(delta) > 1e4) {
      const scale = this._scrollTop / (this.scrollTarget.scrollHeight - this.scrollTarget.clientHeight);
      this._vidxOffset = Math.round(scale * maxOffset);
    } else {
      const oldOffset = this._vidxOffset;
      const threshold = OFFSET_ADJUST_MIN_THRESHOLD;
      const maxShift = 100;
      if (this._scrollTop === 0) {
        this._vidxOffset = 0;
        if (oldOffset !== this._vidxOffset) {
          super.scrollToIndex(0);
        }
      } else if (this.firstVisibleIndex < threshold && this._vidxOffset > 0) {
        this._vidxOffset -= Math.min(this._vidxOffset, maxShift);
        super.scrollToIndex(this.firstVisibleIndex + (oldOffset - this._vidxOffset));
      }
      if (this._scrollTop >= this._maxScrollTop && this._maxScrollTop > 0) {
        this._vidxOffset = maxOffset;
        if (oldOffset !== this._vidxOffset) {
          super.scrollToIndex(this._virtualCount - 1);
        }
      } else if (this.firstVisibleIndex > this._virtualCount - threshold && this._vidxOffset < maxOffset) {
        this._vidxOffset += Math.min(maxOffset - this._vidxOffset, maxShift);
        super.scrollToIndex(this.firstVisibleIndex - (this._vidxOffset - oldOffset));
      }
    }
  }
}
Object.setPrototypeOf(IronListAdapter.prototype, ironList);

// node_modules/@vaadin/component-base/src/virtualizer.js
class Virtualizer {
  constructor(config) {
    this.__adapter = new IronListAdapter(config);
  }
  get firstVisibleIndex() {
    return this.__adapter.adjustedFirstVisibleIndex;
  }
  get lastVisibleIndex() {
    return this.__adapter.adjustedLastVisibleIndex;
  }
  get size() {
    return this.__adapter.size;
  }
  set size(size) {
    this.__adapter.size = size;
  }
  scrollToIndex(index) {
    this.__adapter.scrollToIndex(index);
  }
  update(startIndex = 0, endIndex = this.size - 1) {
    this.__adapter.update(startIndex, endIndex);
  }
  flush() {
    this.__adapter.flush();
  }
  hostConnected() {
    this.__adapter.hostConnected();
  }
}

// node_modules/@vaadin/grid/src/vaadin-grid-a11y-mixin.js
var A11yMixin = (superClass) => class A11yMixin2 extends superClass {
  static get properties() {
    return {
      accessibleName: {
        type: String
      }
    };
  }
  static get observers() {
    return ["__a11yUpdateGridSize(size, _columnTree, __emptyState)"];
  }
  __a11yGetHeaderRowCount(_columnTree) {
    return _columnTree.filter((level) => level.some((col) => col.headerRenderer || col.path && col.header !== null || col.header)).length;
  }
  __a11yGetFooterRowCount(_columnTree) {
    return _columnTree.filter((level) => level.some((col) => col.footerRenderer)).length;
  }
  __a11yUpdateGridSize(size, _columnTree, emptyState) {
    if (size === undefined || _columnTree === undefined) {
      return;
    }
    const headerRowsCount = this.__a11yGetHeaderRowCount(_columnTree);
    const footerRowsCount = this.__a11yGetFooterRowCount(_columnTree);
    const bodyRowsCount = emptyState ? 1 : size;
    const rowsCount = bodyRowsCount + headerRowsCount + footerRowsCount;
    this.$.table.setAttribute("aria-rowcount", rowsCount);
    const bodyColumns = _columnTree[_columnTree.length - 1];
    const columnsCount = emptyState ? 1 : rowsCount && bodyColumns && bodyColumns.length || 0;
    this.$.table.setAttribute("aria-colcount", columnsCount);
    this.__a11yUpdateHeaderRows();
    this.__a11yUpdateFooterRows();
  }
  __a11yUpdateHeaderRows() {
    iterateChildren(this.$.header, (headerRow, index) => {
      headerRow.setAttribute("aria-rowindex", index + 1);
    });
  }
  __a11yUpdateFooterRows() {
    iterateChildren(this.$.footer, (footerRow, index) => {
      footerRow.setAttribute("aria-rowindex", this.__a11yGetHeaderRowCount(this._columnTree) + this.size + index + 1);
    });
  }
  __a11yUpdateRowRowindex(row) {
    row.setAttribute("aria-rowindex", row.index + this.__a11yGetHeaderRowCount(this._columnTree) + 1);
  }
  __a11yUpdateRowSelected(row, selected) {
    row.setAttribute("aria-selected", Boolean(selected));
    iterateRowCells(row, (cell) => {
      cell.setAttribute("aria-selected", Boolean(selected));
    });
  }
  __a11yUpdateRowExpanded(row) {
    const toggleCell = findTreeToggleCell(row);
    if (this.__isRowExpandable(row)) {
      row.setAttribute("aria-expanded", "false");
      if (toggleCell) {
        toggleCell.setAttribute("aria-expanded", "false");
      }
    } else if (this.__isRowCollapsible(row)) {
      row.setAttribute("aria-expanded", "true");
      if (toggleCell) {
        toggleCell.setAttribute("aria-expanded", "true");
      }
    } else {
      row.removeAttribute("aria-expanded");
      if (toggleCell) {
        toggleCell.removeAttribute("aria-expanded");
      }
    }
  }
  __a11yUpdateRowLevel(row, level) {
    if (level > 0 || this.__isRowCollapsible(row) || this.__isRowExpandable(row)) {
      row.setAttribute("aria-level", level + 1);
    } else {
      row.removeAttribute("aria-level");
    }
  }
  __a11ySetRowDetailsCell(row, detailsCell) {
    iterateRowCells(row, (cell) => {
      if (cell !== detailsCell) {
        cell.setAttribute("aria-controls", detailsCell.id);
      }
    });
  }
  __a11yUpdateCellColspan(cell, colspan) {
    cell.setAttribute("aria-colspan", Number(colspan));
  }
  __a11yUpdateSorters() {
    Array.from(this.querySelectorAll("vaadin-grid-sorter")).forEach((sorter) => {
      let cellContent = sorter.parentNode;
      while (cellContent && cellContent.localName !== "vaadin-grid-cell-content") {
        cellContent = cellContent.parentNode;
      }
      if (cellContent && cellContent.assignedSlot) {
        const cell = cellContent.assignedSlot.parentNode;
        cell.setAttribute("aria-sort", {
          asc: "ascending",
          desc: "descending"
        }[String(sorter.direction)] || "none");
      }
    });
  }
};

// node_modules/@vaadin/a11y-base/src/focus-utils.js
var keyboardActive = false;
window.addEventListener("keydown", () => {
  keyboardActive = true;
}, { capture: true });
window.addEventListener("mousedown", () => {
  keyboardActive = false;
}, { capture: true });
function isKeyboardActive() {
  return keyboardActive;
}
function isElementHiddenDirectly(element) {
  const style = element.style;
  if (style.visibility === "hidden" || style.display === "none") {
    return true;
  }
  const computedStyle = window.getComputedStyle(element);
  if (computedStyle.visibility === "hidden" || computedStyle.display === "none") {
    return true;
  }
  return false;
}
function isElementHidden(element) {
  if (element.checkVisibility) {
    return !element.checkVisibility({ visibilityProperty: true });
  }
  if (element.offsetParent === null && element.clientWidth === 0 && element.clientHeight === 0) {
    return true;
  }
  return isElementHiddenDirectly(element);
}
function isElementFocusable(element) {
  if (element.matches('[tabindex="-1"]')) {
    return false;
  }
  if (element.matches("input, select, textarea, button, object")) {
    return element.matches(":not([disabled])");
  }
  return element.matches("a[href], area[href], iframe, [tabindex], [contentEditable]");
}

// node_modules/@vaadin/grid/src/vaadin-grid-active-item-mixin.js
var isFocusable = (target) => {
  return target.offsetParent && !target.part.contains("body-cell") && isElementFocusable(target) && getComputedStyle(target).visibility !== "hidden";
};
var ActiveItemMixin = (superClass) => class ActiveItemMixin2 extends superClass {
  static get properties() {
    return {
      activeItem: {
        type: Object,
        notify: true,
        value: null,
        sync: true
      }
    };
  }
  ready() {
    super.ready();
    this.$.scroller.addEventListener("click", this._onClick.bind(this));
    this.addEventListener("cell-activate", this._activateItem.bind(this));
    this.addEventListener("row-activate", this._activateItem.bind(this));
  }
  _activateItem(e) {
    const model = e.detail.model;
    const clickedItem = model ? model.item : null;
    if (clickedItem) {
      this.activeItem = !this._itemsEqual(this.activeItem, clickedItem) ? clickedItem : null;
    }
  }
  _shouldPreventCellActivationOnClick(e) {
    const { cell } = this._getGridEventLocation(e);
    return e.defaultPrevented || !cell || cell.part.contains("details-cell") || cell === this.$.emptystatecell || cell._content.contains(this.getRootNode().activeElement) || this._isFocusable(e.target) || e.target instanceof HTMLLabelElement;
  }
  _onClick(e) {
    if (this._shouldPreventCellActivationOnClick(e)) {
      return;
    }
    const { cell } = this._getGridEventLocation(e);
    if (cell) {
      this.dispatchEvent(new CustomEvent("cell-activate", {
        detail: {
          model: this.__getRowModel(cell.parentElement)
        }
      }));
    }
  }
  _isFocusable(target) {
    return isFocusable(target);
  }
};

// node_modules/@vaadin/grid/src/array-data-provider.js
function get2(path, object) {
  return path.split(".").reduce((obj, property) => obj[property], object);
}
function checkPaths(arrayToCheck, action, items) {
  if (items.length === 0) {
    return false;
  }
  let result = true;
  arrayToCheck.forEach(({ path }) => {
    if (!path || path.indexOf(".") === -1) {
      return;
    }
    const parentProperty = path.replace(/\.[^.]*$/u, "");
    if (get2(parentProperty, items[0]) === undefined) {
      console.warn(`Path "${path}" used for ${action} does not exist in all of the items, ${action} is disabled.`);
      result = false;
    }
  });
  return result;
}
function normalizeEmptyValue(value) {
  if ([undefined, null].indexOf(value) >= 0) {
    return "";
  } else if (isNaN(value)) {
    return value.toString();
  }
  return value;
}
function compare(a, b) {
  a = normalizeEmptyValue(a);
  b = normalizeEmptyValue(b);
  if (a < b) {
    return -1;
  }
  if (a > b) {
    return 1;
  }
  return 0;
}
function multiSort(items, sortOrders) {
  return items.sort((a, b) => {
    return sortOrders.map((sortOrder) => {
      if (sortOrder.direction === "asc") {
        return compare(get2(sortOrder.path, a), get2(sortOrder.path, b));
      } else if (sortOrder.direction === "desc") {
        return compare(get2(sortOrder.path, b), get2(sortOrder.path, a));
      }
      return 0;
    }).reduce((p, n) => {
      return p !== 0 ? p : n;
    }, 0);
  });
}
function filter(items, filters) {
  return items.filter((item) => {
    return filters.every((filter2) => {
      const value = normalizeEmptyValue(get2(filter2.path, item));
      const filterValueLowercase = normalizeEmptyValue(filter2.value).toString().toLowerCase();
      return value.toString().toLowerCase().includes(filterValueLowercase);
    });
  });
}
var createArrayDataProvider = (allItems) => {
  return (params, callback) => {
    let items = allItems ? [...allItems] : [];
    if (params.filters && checkPaths(params.filters, "filtering", items)) {
      items = filter(items, params.filters);
    }
    if (Array.isArray(params.sortOrders) && params.sortOrders.length && checkPaths(params.sortOrders, "sorting", items)) {
      items = multiSort(items, params.sortOrders);
    }
    const count = Math.min(items.length, params.pageSize);
    const start = params.page * count;
    const end = start + count;
    const slice = items.slice(start, end);
    callback(slice, items.length);
  };
};

// node_modules/@vaadin/grid/src/vaadin-grid-array-data-provider-mixin.js
var ArrayDataProviderMixin = (superClass) => class ArrayDataProviderMixin2 extends superClass {
  static get properties() {
    return {
      items: {
        type: Array,
        sync: true
      }
    };
  }
  static get observers() {
    return ["__dataProviderOrItemsChanged(dataProvider, items, isAttached, items.*)"];
  }
  __setArrayDataProvider(items) {
    const arrayDataProvider = createArrayDataProvider(this.items, {});
    arrayDataProvider.__items = items;
    this._arrayDataProvider = arrayDataProvider;
    this.size = items.length;
    this.dataProvider = arrayDataProvider;
  }
  _onDataProviderPageReceived() {
    super._onDataProviderPageReceived();
    if (this._arrayDataProvider) {
      this.size = this._flatSize;
    }
  }
  __dataProviderOrItemsChanged(dataProvider, items, isAttached) {
    if (!isAttached) {
      return;
    }
    if (this._arrayDataProvider) {
      if (dataProvider !== this._arrayDataProvider) {
        this._arrayDataProvider = undefined;
        this.items = undefined;
      } else if (!items) {
        this._arrayDataProvider = undefined;
        this.dataProvider = undefined;
        this.size = 0;
        this.clearCache();
      } else if (this._arrayDataProvider.__items === items) {
        this.clearCache();
      } else {
        this.__setArrayDataProvider(items);
      }
    } else if (items) {
      this.__setArrayDataProvider(items);
    }
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-column-auto-width-mixin.js
var ColumnAutoWidthMixin = (superClass) => class extends superClass {
  static get properties() {
    return {
      __pendingRecalculateColumnWidths: {
        type: Boolean,
        value: true
      }
    };
  }
  static get observers() {
    return [
      "__dataProviderChangedAutoWidth(dataProvider)",
      "__columnTreeChangedAutoWidth(_columnTree)",
      "__flatSizeChangedAutoWidth(_flatSize)"
    ];
  }
  updated(props) {
    super.updated(props);
    if (props.has("__hostVisible") && !props.get("__hostVisible")) {
      this.__tryToRecalculateColumnWidthsIfPending();
    }
  }
  __dataProviderChangedAutoWidth(_dataProvider) {
    if (this.__hasHadRenderedRowsForColumnWidthCalculation) {
      return;
    }
    this.recalculateColumnWidths();
  }
  __columnTreeChangedAutoWidth(_columnTree) {
    queueMicrotask(() => this.recalculateColumnWidths());
  }
  __flatSizeChangedAutoWidth(flatSize) {
    requestAnimationFrame(() => {
      if (!!flatSize && !this.__hasHadRenderedRowsForColumnWidthCalculation) {
        this.recalculateColumnWidths();
      } else {
        this.__tryToRecalculateColumnWidthsIfPending();
      }
    });
  }
  _onDataProviderPageLoaded() {
    super._onDataProviderPageLoaded();
    this.__tryToRecalculateColumnWidthsIfPending();
  }
  _updateFrozenColumn() {
    super._updateFrozenColumn();
    this.__tryToRecalculateColumnWidthsIfPending();
  }
  __getIntrinsicWidth(col) {
    if (!this.__intrinsicWidthCache.has(col)) {
      this.__calculateAndCacheIntrinsicWidths([col]);
    }
    return this.__intrinsicWidthCache.get(col);
  }
  __getDistributedWidth(col, innerColumn) {
    if (col == null || col === this) {
      return 0;
    }
    const columnWidth = Math.max(this.__getIntrinsicWidth(col), this.__getDistributedWidth(this.__getParentColumnGroup(col), col));
    if (!innerColumn) {
      return columnWidth;
    }
    const columnGroup = col;
    const columnGroupWidth = columnWidth;
    const sumOfWidthOfAllChildColumns = columnGroup._visibleChildColumns.map((col2) => this.__getIntrinsicWidth(col2)).reduce((sum, curr) => sum + curr, 0);
    const extraNecessarySpaceForGridColumnGroup = Math.max(0, columnGroupWidth - sumOfWidthOfAllChildColumns);
    const proportionOfExtraSpace = this.__getIntrinsicWidth(innerColumn) / sumOfWidthOfAllChildColumns;
    const shareOfInnerColumnFromNecessaryExtraSpace = proportionOfExtraSpace * extraNecessarySpaceForGridColumnGroup;
    return this.__getIntrinsicWidth(innerColumn) + shareOfInnerColumnFromNecessaryExtraSpace;
  }
  _recalculateColumnWidths() {
    this.__virtualizer.flush();
    [...this.$.header.children, ...this.$.footer.children].forEach((row) => {
      if (row.__debounceUpdateHeaderFooterRowVisibility) {
        row.__debounceUpdateHeaderFooterRowVisibility.flush();
      }
    });
    this.__hasHadRenderedRowsForColumnWidthCalculation = this.__hasHadRenderedRowsForColumnWidthCalculation || this._getRenderedRows().length > 0;
    this.__intrinsicWidthCache = new Map;
    const fvi = this._firstVisibleIndex;
    const lvi = this._lastVisibleIndex;
    this.__viewportRowsCache = this._getRenderedRows().filter((row) => row.index >= fvi && row.index <= lvi);
    const cols = this.__getAutoWidthColumns();
    const ancestorColumnGroups = new Set;
    for (const col of cols) {
      let parent = this.__getParentColumnGroup(col);
      while (parent && !ancestorColumnGroups.has(parent)) {
        ancestorColumnGroups.add(parent);
        parent = this.__getParentColumnGroup(parent);
      }
    }
    this.__calculateAndCacheIntrinsicWidths([...cols, ...ancestorColumnGroups]);
    cols.forEach((col) => {
      col.width = `${this.__getDistributedWidth(col)}px`;
    });
    this.__intrinsicWidthCache.clear();
  }
  __getParentColumnGroup(col) {
    const parent = (col.assignedSlot || col).parentElement;
    return parent && parent !== this ? parent : null;
  }
  __setVisibleCellContentAutoWidth(col, autoWidth) {
    col._allCells.filter((cell) => {
      if (this.$.items.contains(cell)) {
        return this.__viewportRowsCache.includes(cell.parentElement);
      }
      return true;
    }).forEach((cell) => {
      cell.__measuringAutoWidth = autoWidth;
      if (cell.__measuringAutoWidth) {
        cell.__originalWidth = cell.style.width;
        cell.style.width = "auto";
        cell.style.position = "absolute";
      } else {
        cell.style.width = cell.__originalWidth;
        delete cell.__originalWidth;
        cell.style.position = "";
      }
    });
    if (autoWidth) {
      this.$.scroller.setAttribute("measuring-auto-width", "");
    } else {
      this.$.scroller.removeAttribute("measuring-auto-width");
    }
  }
  __getAutoWidthCellsMaxWidth(col) {
    return col._allCells.reduce((width, cell) => {
      return cell.__measuringAutoWidth ? Math.max(width, cell.offsetWidth + 1) : width;
    }, 0);
  }
  __calculateAndCacheIntrinsicWidths(cols) {
    cols.forEach((col) => this.__setVisibleCellContentAutoWidth(col, true));
    cols.forEach((col) => {
      const width = this.__getAutoWidthCellsMaxWidth(col);
      this.__intrinsicWidthCache.set(col, width);
    });
    cols.forEach((col) => this.__setVisibleCellContentAutoWidth(col, false));
  }
  recalculateColumnWidths() {
    if (!this.__isReadyForColumnWidthCalculation()) {
      this.__pendingRecalculateColumnWidths = true;
      return;
    }
    this._recalculateColumnWidths();
  }
  __tryToRecalculateColumnWidthsIfPending() {
    if (!this.__pendingRecalculateColumnWidths) {
      return;
    }
    this.__pendingRecalculateColumnWidths = false;
    this.recalculateColumnWidths();
  }
  __getAutoWidthColumns() {
    return this._getColumns().filter((col) => !col.hidden && col.autoWidth);
  }
  __isReadyForColumnWidthCalculation() {
    if (!this._columnTree) {
      return false;
    }
    const undefinedCols = this.__getAutoWidthColumns().filter((col) => !customElements.get(col.localName));
    if (undefinedCols.length) {
      Promise.all(undefinedCols.map((col) => customElements.whenDefined(col.localName))).then(() => {
        this.__tryToRecalculateColumnWidthsIfPending();
      });
      return false;
    }
    const hasRowsWithUndefinedIndex = [...this.$.items.children].some((row) => row.index === undefined);
    const debouncingHiddenChanged = this._debouncerHiddenChanged && this._debouncerHiddenChanged.isActive();
    const debouncingUpdateFrozenColumn = this.__debounceUpdateFrozenColumn && this.__debounceUpdateFrozenColumn.isActive();
    const hasHeight = this.clientHeight > 0;
    return !this._dataProviderController.isLoading() && !hasRowsWithUndefinedIndex && !isElementHidden(this) && !debouncingHiddenChanged && !debouncingUpdateFrozenColumn && hasHeight;
  }
};

// node_modules/@vaadin/component-base/src/gestures.js
var passiveTouchGestures = false;
var wrap2 = (node) => node;
var HAS_NATIVE_TA = typeof document.head.style.touchAction === "string";
var GESTURE_KEY = "__polymerGestures";
var HANDLED_OBJ = "__polymerGesturesHandled";
var TOUCH_ACTION = "__polymerGesturesTouchAction";
var TAP_DISTANCE = 25;
var TRACK_DISTANCE = 5;
var TRACK_LENGTH = 2;
var MOUSE_EVENTS = ["mousedown", "mousemove", "mouseup", "click"];
var MOUSE_WHICH_TO_BUTTONS = [0, 1, 4, 2];
var MOUSE_HAS_BUTTONS = function() {
  try {
    return new MouseEvent("test", { buttons: 1 }).buttons === 1;
  } catch (_) {
    return false;
  }
}();
function isMouseEvent(name) {
  return MOUSE_EVENTS.indexOf(name) > -1;
}
var supportsPassive = false;
(function() {
  try {
    const opts = Object.defineProperty({}, "passive", {
      get() {
        supportsPassive = true;
      }
    });
    window.addEventListener("test", null, opts);
    window.removeEventListener("test", null, opts);
  } catch (_) {}
})();
function PASSIVE_TOUCH(eventName) {
  if (isMouseEvent(eventName) || eventName === "touchend") {
    return;
  }
  if (HAS_NATIVE_TA && supportsPassive && passiveTouchGestures) {
    return { passive: true };
  }
}
var IS_TOUCH_ONLY = navigator.userAgent.match(/iP(?:[oa]d|hone)|Android/u);
var canBeDisabled = {
  button: true,
  command: true,
  fieldset: true,
  input: true,
  keygen: true,
  optgroup: true,
  option: true,
  select: true,
  textarea: true
};
function hasLeftMouseButton(ev) {
  const type = ev.type;
  if (!isMouseEvent(type)) {
    return false;
  }
  if (type === "mousemove") {
    let buttons = ev.buttons === undefined ? 1 : ev.buttons;
    if (ev instanceof window.MouseEvent && !MOUSE_HAS_BUTTONS) {
      buttons = MOUSE_WHICH_TO_BUTTONS[ev.which] || 0;
    }
    return Boolean(buttons & 1);
  }
  const button = ev.button === undefined ? 0 : ev.button;
  return button === 0;
}
function isSyntheticClick(ev) {
  if (ev.type === "click") {
    if (ev.detail === 0) {
      return true;
    }
    const t = _findOriginalTarget(ev);
    if (!t.nodeType || t.nodeType !== Node.ELEMENT_NODE) {
      return true;
    }
    const bcr = t.getBoundingClientRect();
    const { pageX: x, pageY: y } = ev;
    return !(x >= bcr.left && x <= bcr.right && y >= bcr.top && y <= bcr.bottom);
  }
  return false;
}
var POINTERSTATE = {
  mouse: {
    target: null,
    mouseIgnoreJob: null
  },
  touch: {
    x: 0,
    y: 0,
    id: -1,
    scrollDecided: false
  }
};
function firstTouchAction(ev) {
  let ta = "auto";
  const path = getComposedPath(ev);
  for (let i = 0, n;i < path.length; i++) {
    n = path[i];
    if (n[TOUCH_ACTION]) {
      ta = n[TOUCH_ACTION];
      break;
    }
  }
  return ta;
}
function trackDocument(stateObj, movefn, upfn) {
  stateObj.movefn = movefn;
  stateObj.upfn = upfn;
  document.addEventListener("mousemove", movefn);
  document.addEventListener("mouseup", upfn);
}
function untrackDocument(stateObj) {
  document.removeEventListener("mousemove", stateObj.movefn);
  document.removeEventListener("mouseup", stateObj.upfn);
  stateObj.movefn = null;
  stateObj.upfn = null;
}
var getComposedPath = window.ShadyDOM && window.ShadyDOM.noPatch ? window.ShadyDOM.composedPath : (event) => event.composedPath && event.composedPath() || [];
var gestures = {};
var recognizers = [];
function deepTargetFind(x, y) {
  let node = document.elementFromPoint(x, y);
  let next = node;
  while (next && next.shadowRoot && !window.ShadyDOM) {
    const oldNext = next;
    next = next.shadowRoot.elementFromPoint(x, y);
    if (oldNext === next) {
      break;
    }
    if (next) {
      node = next;
    }
  }
  return node;
}
function _findOriginalTarget(ev) {
  const path = getComposedPath(ev);
  return path.length > 0 ? path[0] : ev.target;
}
function _handleNative(ev) {
  const type = ev.type;
  const node = ev.currentTarget;
  const gobj = node[GESTURE_KEY];
  if (!gobj) {
    return;
  }
  const gs = gobj[type];
  if (!gs) {
    return;
  }
  if (!ev[HANDLED_OBJ]) {
    ev[HANDLED_OBJ] = {};
    if (type.startsWith("touch")) {
      const t = ev.changedTouches[0];
      if (type === "touchstart") {
        if (ev.touches.length === 1) {
          POINTERSTATE.touch.id = t.identifier;
        }
      }
      if (POINTERSTATE.touch.id !== t.identifier) {
        return;
      }
      if (!HAS_NATIVE_TA) {
        if (type === "touchstart" || type === "touchmove") {
          _handleTouchAction(ev);
        }
      }
    }
  }
  const handled = ev[HANDLED_OBJ];
  if (handled.skip) {
    return;
  }
  for (let i = 0, r;i < recognizers.length; i++) {
    r = recognizers[i];
    if (gs[r.name] && !handled[r.name]) {
      if (r.flow && r.flow.start.indexOf(ev.type) > -1 && r.reset) {
        r.reset();
      }
    }
  }
  for (let i = 0, r;i < recognizers.length; i++) {
    r = recognizers[i];
    if (gs[r.name] && !handled[r.name]) {
      handled[r.name] = true;
      r[type](ev);
    }
  }
}
function _handleTouchAction(ev) {
  const t = ev.changedTouches[0];
  const type = ev.type;
  if (type === "touchstart") {
    POINTERSTATE.touch.x = t.clientX;
    POINTERSTATE.touch.y = t.clientY;
    POINTERSTATE.touch.scrollDecided = false;
  } else if (type === "touchmove") {
    if (POINTERSTATE.touch.scrollDecided) {
      return;
    }
    POINTERSTATE.touch.scrollDecided = true;
    const ta = firstTouchAction(ev);
    let shouldPrevent = false;
    const dx = Math.abs(POINTERSTATE.touch.x - t.clientX);
    const dy = Math.abs(POINTERSTATE.touch.y - t.clientY);
    if (!ev.cancelable) {} else if (ta === "none") {
      shouldPrevent = true;
    } else if (ta === "pan-x") {
      shouldPrevent = dy > dx;
    } else if (ta === "pan-y") {
      shouldPrevent = dx > dy;
    }
    if (shouldPrevent) {
      ev.preventDefault();
    } else {
      prevent("track");
    }
  }
}
function addListener(node, evType, handler) {
  if (gestures[evType]) {
    _add(node, evType, handler);
    return true;
  }
  return false;
}
function _add(node, evType, handler) {
  const recognizer = gestures[evType];
  const deps = recognizer.deps;
  const name = recognizer.name;
  let gobj = node[GESTURE_KEY];
  if (!gobj) {
    node[GESTURE_KEY] = gobj = {};
  }
  for (let i = 0, dep, gd;i < deps.length; i++) {
    dep = deps[i];
    if (IS_TOUCH_ONLY && isMouseEvent(dep) && dep !== "click") {
      continue;
    }
    gd = gobj[dep];
    if (!gd) {
      gobj[dep] = gd = { _count: 0 };
    }
    if (gd._count === 0) {
      node.addEventListener(dep, _handleNative, PASSIVE_TOUCH(dep));
    }
    gd[name] = (gd[name] || 0) + 1;
    gd._count = (gd._count || 0) + 1;
  }
  node.addEventListener(evType, handler);
  if (recognizer.touchAction) {
    setTouchAction(node, recognizer.touchAction);
  }
}
function register(recog) {
  recognizers.push(recog);
  recog.emits.forEach((emit) => {
    gestures[emit] = recog;
  });
}
function _findRecognizerByEvent(evName) {
  for (let i = 0, r;i < recognizers.length; i++) {
    r = recognizers[i];
    for (let j = 0, n;j < r.emits.length; j++) {
      n = r.emits[j];
      if (n === evName) {
        return r;
      }
    }
  }
  return null;
}
function setTouchAction(node, value) {
  if (HAS_NATIVE_TA && node instanceof HTMLElement) {
    microTask.run(() => {
      node.style.touchAction = value;
    });
  }
  node[TOUCH_ACTION] = value;
}
function _fire(target, type, detail) {
  const ev = new Event(type, { bubbles: true, cancelable: true, composed: true });
  ev.detail = detail;
  wrap2(target).dispatchEvent(ev);
  if (ev.defaultPrevented) {
    const preventer = detail.preventer || detail.sourceEvent;
    if (preventer && preventer.preventDefault) {
      preventer.preventDefault();
    }
  }
}
function prevent(evName) {
  const recognizer = _findRecognizerByEvent(evName);
  if (recognizer.info) {
    recognizer.info.prevent = true;
  }
}
register({
  name: "downup",
  deps: ["mousedown", "touchstart", "touchend"],
  flow: {
    start: ["mousedown", "touchstart"],
    end: ["mouseup", "touchend"]
  },
  emits: ["down", "up"],
  info: {
    movefn: null,
    upfn: null
  },
  reset() {
    untrackDocument(this.info);
  },
  mousedown(e) {
    if (!hasLeftMouseButton(e)) {
      return;
    }
    const t = _findOriginalTarget(e);
    const self = this;
    const movefn = (e2) => {
      if (!hasLeftMouseButton(e2)) {
        downupFire("up", t, e2);
        untrackDocument(self.info);
      }
    };
    const upfn = (e2) => {
      if (hasLeftMouseButton(e2)) {
        downupFire("up", t, e2);
      }
      untrackDocument(self.info);
    };
    trackDocument(this.info, movefn, upfn);
    downupFire("down", t, e);
  },
  touchstart(e) {
    downupFire("down", _findOriginalTarget(e), e.changedTouches[0], e);
  },
  touchend(e) {
    downupFire("up", _findOriginalTarget(e), e.changedTouches[0], e);
  }
});
function downupFire(type, target, event, preventer) {
  if (!target) {
    return;
  }
  _fire(target, type, {
    x: event.clientX,
    y: event.clientY,
    sourceEvent: event,
    preventer,
    prevent(e) {
      return prevent(e);
    }
  });
}
register({
  name: "track",
  touchAction: "none",
  deps: ["mousedown", "touchstart", "touchmove", "touchend"],
  flow: {
    start: ["mousedown", "touchstart"],
    end: ["mouseup", "touchend"]
  },
  emits: ["track"],
  info: {
    x: 0,
    y: 0,
    state: "start",
    started: false,
    moves: [],
    addMove(move) {
      if (this.moves.length > TRACK_LENGTH) {
        this.moves.shift();
      }
      this.moves.push(move);
    },
    movefn: null,
    upfn: null,
    prevent: false
  },
  reset() {
    this.info.state = "start";
    this.info.started = false;
    this.info.moves = [];
    this.info.x = 0;
    this.info.y = 0;
    this.info.prevent = false;
    untrackDocument(this.info);
  },
  mousedown(e) {
    if (!hasLeftMouseButton(e)) {
      return;
    }
    const t = _findOriginalTarget(e);
    const self = this;
    const movefn = (e2) => {
      const { clientX: x, clientY: y } = e2;
      if (trackHasMovedEnough(self.info, x, y)) {
        self.info.state = self.info.started ? e2.type === "mouseup" ? "end" : "track" : "start";
        if (self.info.state === "start") {
          prevent("tap");
        }
        self.info.addMove({ x, y });
        if (!hasLeftMouseButton(e2)) {
          self.info.state = "end";
          untrackDocument(self.info);
        }
        if (t) {
          trackFire(self.info, t, e2);
        }
        self.info.started = true;
      }
    };
    const upfn = (e2) => {
      if (self.info.started) {
        movefn(e2);
      }
      untrackDocument(self.info);
    };
    trackDocument(this.info, movefn, upfn);
    this.info.x = e.clientX;
    this.info.y = e.clientY;
  },
  touchstart(e) {
    const ct = e.changedTouches[0];
    this.info.x = ct.clientX;
    this.info.y = ct.clientY;
  },
  touchmove(e) {
    const t = _findOriginalTarget(e);
    const ct = e.changedTouches[0];
    const { clientX: x, clientY: y } = ct;
    if (trackHasMovedEnough(this.info, x, y)) {
      if (this.info.state === "start") {
        prevent("tap");
      }
      this.info.addMove({ x, y });
      trackFire(this.info, t, ct);
      this.info.state = "track";
      this.info.started = true;
    }
  },
  touchend(e) {
    const t = _findOriginalTarget(e);
    const ct = e.changedTouches[0];
    if (this.info.started) {
      this.info.state = "end";
      this.info.addMove({ x: ct.clientX, y: ct.clientY });
      trackFire(this.info, t, ct);
    }
  }
});
function trackHasMovedEnough(info, x, y) {
  if (info.prevent) {
    return false;
  }
  if (info.started) {
    return true;
  }
  const dx = Math.abs(info.x - x);
  const dy = Math.abs(info.y - y);
  return dx >= TRACK_DISTANCE || dy >= TRACK_DISTANCE;
}
function trackFire(info, target, touch) {
  if (!target) {
    return;
  }
  const secondlast = info.moves[info.moves.length - 2];
  const lastmove = info.moves[info.moves.length - 1];
  const dx = lastmove.x - info.x;
  const dy = lastmove.y - info.y;
  let ddx, ddy = 0;
  if (secondlast) {
    ddx = lastmove.x - secondlast.x;
    ddy = lastmove.y - secondlast.y;
  }
  _fire(target, "track", {
    state: info.state,
    x: touch.clientX,
    y: touch.clientY,
    dx,
    dy,
    ddx,
    ddy,
    sourceEvent: touch,
    hover() {
      return deepTargetFind(touch.clientX, touch.clientY);
    }
  });
}
register({
  name: "tap",
  deps: ["mousedown", "click", "touchstart", "touchend"],
  flow: {
    start: ["mousedown", "touchstart"],
    end: ["click", "touchend"]
  },
  emits: ["tap"],
  info: {
    x: NaN,
    y: NaN,
    prevent: false
  },
  reset() {
    this.info.x = NaN;
    this.info.y = NaN;
    this.info.prevent = false;
  },
  mousedown(e) {
    if (hasLeftMouseButton(e)) {
      this.info.x = e.clientX;
      this.info.y = e.clientY;
    }
  },
  click(e) {
    if (hasLeftMouseButton(e)) {
      trackForward(this.info, e);
    }
  },
  touchstart(e) {
    const touch = e.changedTouches[0];
    this.info.x = touch.clientX;
    this.info.y = touch.clientY;
  },
  touchend(e) {
    trackForward(this.info, e.changedTouches[0], e);
  }
});
function trackForward(info, e, preventer) {
  const dx = Math.abs(e.clientX - info.x);
  const dy = Math.abs(e.clientY - info.y);
  const t = _findOriginalTarget(preventer || e);
  if (!t || canBeDisabled[t.localName] && t.hasAttribute("disabled")) {
    return;
  }
  if (isNaN(dx) || isNaN(dy) || dx <= TAP_DISTANCE && dy <= TAP_DISTANCE || isSyntheticClick(e)) {
    if (!info.prevent) {
      _fire(t, "tap", {
        x: e.clientX,
        y: e.clientY,
        sourceEvent: e,
        preventer
      });
    }
  }
}

// node_modules/@vaadin/grid/src/vaadin-grid-column-reordering-mixin.js
var ColumnReorderingMixin = (superClass) => class ColumnReorderingMixin2 extends superClass {
  static get properties() {
    return {
      columnReorderingAllowed: {
        type: Boolean,
        value: false
      },
      _orderBaseScope: {
        type: Number,
        value: 1e7
      }
    };
  }
  static get observers() {
    return ["_updateOrders(_columnTree)"];
  }
  ready() {
    super.ready();
    addListener(this, "track", this._onTrackEvent);
    this._reorderGhost = this.shadowRoot.querySelector('[part="reorder-ghost"]');
    this.addEventListener("touchstart", this._onTouchStart.bind(this));
    this.addEventListener("touchmove", this._onTouchMove.bind(this));
    this.addEventListener("touchend", this._onTouchEnd.bind(this));
    this.addEventListener("contextmenu", this._onContextMenu.bind(this));
  }
  _onContextMenu(e) {
    if (this.hasAttribute("reordering")) {
      e.preventDefault();
      if (!isTouch) {
        this._onTrackEnd();
      }
    }
  }
  _onTouchStart(e) {
    this._startTouchReorderTimeout = setTimeout(() => {
      this._onTrackStart({
        detail: {
          x: e.touches[0].clientX,
          y: e.touches[0].clientY
        }
      });
    }, 100);
  }
  _onTouchMove(e) {
    if (this._draggedColumn) {
      e.preventDefault();
    }
    clearTimeout(this._startTouchReorderTimeout);
  }
  _onTouchEnd() {
    clearTimeout(this._startTouchReorderTimeout);
    this._onTrackEnd();
  }
  _onTrackEvent(e) {
    if (e.detail.state === "start") {
      const path = e.composedPath();
      const headerCell = path[path.indexOf(this.$.header) - 2];
      if (!headerCell || !headerCell._content) {
        return;
      }
      if (headerCell._content.contains(this.getRootNode().activeElement)) {
        return;
      }
      if (this.$.scroller.hasAttribute("column-resizing")) {
        return;
      }
      if (!this._touchDevice) {
        this._onTrackStart(e);
      }
    } else if (e.detail.state === "track") {
      this._onTrack(e);
    } else if (e.detail.state === "end") {
      this._onTrackEnd(e);
    }
  }
  _onTrackStart(e) {
    if (!this.columnReorderingAllowed) {
      return;
    }
    const path = e.composedPath && e.composedPath();
    if (path && path.slice(0, Math.max(0, path.indexOf(this))).some((node) => node.draggable)) {
      return;
    }
    const headerCell = this._cellFromPoint(e.detail.x, e.detail.y);
    if (!headerCell || !headerCell.part.contains("header-cell")) {
      return;
    }
    this.toggleAttribute("reordering", true);
    this._draggedColumn = headerCell._column;
    while (this._draggedColumn.parentElement.childElementCount === 1) {
      this._draggedColumn = this._draggedColumn.parentElement;
    }
    this._setSiblingsReorderStatus(this._draggedColumn, "allowed");
    this._draggedColumn._reorderStatus = "dragging";
    this._updateGhost(headerCell);
    this._reorderGhost.style.visibility = "visible";
    this._updateGhostPosition(e.detail.x, this._touchDevice ? e.detail.y - 50 : e.detail.y);
    this._autoScroller();
  }
  _onTrack(e) {
    if (!this._draggedColumn) {
      return;
    }
    const targetCell = this._cellFromPoint(e.detail.x, e.detail.y);
    if (!targetCell) {
      return;
    }
    const targetColumn = this._getTargetColumn(targetCell, this._draggedColumn);
    if (this._isSwapAllowed(this._draggedColumn, targetColumn) && this._isSwappableByPosition(targetColumn, e.detail.x)) {
      const columnTreeLevel = this._columnTree.findIndex((level) => level.includes(targetColumn));
      const levelColumnsInOrder = this._getColumnsInOrder(columnTreeLevel);
      const startIndex = levelColumnsInOrder.indexOf(this._draggedColumn);
      const endIndex = levelColumnsInOrder.indexOf(targetColumn);
      const direction = startIndex < endIndex ? 1 : -1;
      for (let i = startIndex;i !== endIndex; i += direction) {
        this._swapColumnOrders(this._draggedColumn, levelColumnsInOrder[i + direction]);
      }
    }
    this._updateGhostPosition(e.detail.x, this._touchDevice ? e.detail.y - 50 : e.detail.y);
    this._lastDragClientX = e.detail.x;
  }
  _onTrackEnd() {
    if (!this._draggedColumn) {
      return;
    }
    this.toggleAttribute("reordering", false);
    this._draggedColumn._reorderStatus = "";
    this._setSiblingsReorderStatus(this._draggedColumn, "");
    this._draggedColumn = null;
    this._lastDragClientX = null;
    this._reorderGhost.style.visibility = "hidden";
    this.dispatchEvent(new CustomEvent("column-reorder", {
      detail: {
        columns: this._getColumnsInOrder()
      }
    }));
  }
  _getColumnsInOrder(headerLevel = this._columnTree.length - 1) {
    return this._columnTree[headerLevel].filter((c) => !c.hidden).sort((b, a) => b._order - a._order);
  }
  _cellFromPoint(x = 0, y = 0) {
    if (!this._draggedColumn) {
      this.$.scroller.toggleAttribute("no-content-pointer-events", true);
    }
    const elementFromPoint = this.shadowRoot.elementFromPoint(x, y);
    this.$.scroller.toggleAttribute("no-content-pointer-events", false);
    return this._getCellFromElement(elementFromPoint);
  }
  _getCellFromElement(element) {
    if (element) {
      if (element._column) {
        return element;
      }
      const { parentElement } = element;
      if (parentElement && parentElement._focusButton === element) {
        return parentElement;
      }
    }
    return null;
  }
  _updateGhostPosition(eventClientX, eventClientY) {
    const ghostRect = this._reorderGhost.getBoundingClientRect();
    const targetLeft = eventClientX - ghostRect.width / 2;
    const targetTop = eventClientY - ghostRect.height / 2;
    const _left = parseInt(this._reorderGhost._left || 0);
    const _top = parseInt(this._reorderGhost._top || 0);
    this._reorderGhost._left = _left - (ghostRect.left - targetLeft);
    this._reorderGhost._top = _top - (ghostRect.top - targetTop);
    this._reorderGhost.style.transform = `translate(${this._reorderGhost._left}px, ${this._reorderGhost._top}px)`;
  }
  _updateGhost(cell) {
    const ghost = this._reorderGhost;
    ghost.textContent = cell._content.innerText;
    const style = window.getComputedStyle(cell);
    [
      "boxSizing",
      "display",
      "width",
      "height",
      "background",
      "alignItems",
      "padding",
      "border",
      "flex-direction",
      "overflow"
    ].forEach((propertyName) => {
      ghost.style[propertyName] = style[propertyName];
    });
    return ghost;
  }
  _updateOrders(columnTree) {
    if (columnTree === undefined) {
      return;
    }
    columnTree[0].forEach((column) => {
      column._order = 0;
    });
    updateColumnOrders(columnTree[0], this._orderBaseScope, 0);
  }
  _setSiblingsReorderStatus(column, status) {
    iterateChildren(column.parentNode, (sibling) => {
      if (/column/u.test(sibling.localName) && this._isSwapAllowed(sibling, column)) {
        sibling._reorderStatus = status;
      }
    });
  }
  _autoScroller() {
    if (this._lastDragClientX) {
      const rightDiff = this._lastDragClientX - this.getBoundingClientRect().right + 50;
      const leftDiff = this.getBoundingClientRect().left - this._lastDragClientX + 50;
      if (rightDiff > 0) {
        this.$.table.scrollLeft += rightDiff / 10;
      } else if (leftDiff > 0) {
        this.$.table.scrollLeft -= leftDiff / 10;
      }
    }
    if (this._draggedColumn) {
      setTimeout(() => this._autoScroller(), 10);
    }
  }
  _isSwapAllowed(column1, column2) {
    if (column1 && column2) {
      const differentColumns = column1 !== column2;
      const sameParent = column1.parentElement === column2.parentElement;
      const sameFrozen = column1.frozen && column2.frozen || column1.frozenToEnd && column2.frozenToEnd || !column1.frozen && !column1.frozenToEnd && !column2.frozen && !column2.frozenToEnd;
      return differentColumns && sameParent && sameFrozen;
    }
  }
  _isSwappableByPosition(targetColumn, clientX) {
    const targetCell = Array.from(this.$.header.querySelectorAll('tr:not([hidden]) [part~="cell"]')).find((cell) => targetColumn.contains(cell._column));
    const sourceCellRect = this.$.header.querySelector("tr:not([hidden]) [reorder-status=dragging]").getBoundingClientRect();
    const targetRect = targetCell.getBoundingClientRect();
    if (targetRect.left > sourceCellRect.left) {
      return clientX > targetRect.right - sourceCellRect.width;
    }
    return clientX < targetRect.left + sourceCellRect.width;
  }
  _swapColumnOrders(column1, column2) {
    [column1._order, column2._order] = [column2._order, column1._order];
    this._debounceUpdateFrozenColumn();
    this._updateFirstAndLastColumn();
  }
  _getTargetColumn(targetCell, draggedColumn) {
    if (targetCell && draggedColumn) {
      let candidate = targetCell._column;
      while (candidate.parentElement !== draggedColumn.parentElement && candidate !== this) {
        candidate = candidate.parentElement;
      }
      if (candidate.parentElement === draggedColumn.parentElement) {
        return candidate;
      }
      return targetCell._column;
    }
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-column-resizing-mixin.js
var ColumnResizingMixin = (superClass) => class ColumnResizingMixin2 extends superClass {
  ready() {
    super.ready();
    const scroller = this.$.scroller;
    addListener(scroller, "track", this._onHeaderTrack.bind(this));
    scroller.addEventListener("touchmove", (e) => scroller.hasAttribute("column-resizing") && e.preventDefault());
    scroller.addEventListener("contextmenu", (e) => e.target.part.contains("resize-handle") && e.preventDefault());
    scroller.addEventListener("mousedown", (e) => e.target.part.contains("resize-handle") && e.preventDefault());
  }
  _onHeaderTrack(e) {
    const handle = e.target;
    if (handle.part.contains("resize-handle")) {
      const cell = handle.parentElement;
      let column = cell._column;
      this.$.scroller.toggleAttribute("column-resizing", true);
      while (column.localName === "vaadin-grid-column-group") {
        column = column._childColumns.slice(0).sort((a, b) => a._order - b._order).filter((column2) => !column2.hidden).pop();
      }
      const isRTL = this.__isRTL;
      const eventX = e.detail.x;
      const columnRowCells = Array.from(this.$.header.querySelectorAll('[part~="row"]:last-child [part~="cell"]'));
      const targetCell = columnRowCells.find((cell2) => cell2._column === column);
      if (targetCell.offsetWidth) {
        const style = getComputedStyle(targetCell._content);
        const minWidth = 10 + parseInt(style.paddingLeft) + parseInt(style.paddingRight) + parseInt(style.borderLeftWidth) + parseInt(style.borderRightWidth) + parseInt(style.marginLeft) + parseInt(style.marginRight);
        let maxWidth;
        const cellWidth = targetCell.offsetWidth;
        const cellRect = targetCell.getBoundingClientRect();
        if (targetCell.hasAttribute("frozen-to-end")) {
          maxWidth = cellWidth + (isRTL ? eventX - cellRect.right : cellRect.left - eventX);
        } else {
          maxWidth = cellWidth + (isRTL ? cellRect.left - eventX : eventX - cellRect.right);
        }
        column.width = `${Math.max(minWidth, maxWidth)}px`;
        column.flexGrow = 0;
      }
      columnRowCells.sort((a, b) => a._column._order - b._column._order).forEach((cell2, index, array) => {
        if (index < array.indexOf(targetCell)) {
          cell2._column.width = `${cell2.offsetWidth}px`;
          cell2._column.flexGrow = 0;
        }
      });
      const cellFrozenToEnd = this._frozenToEndCells[0];
      if (cellFrozenToEnd && this.$.table.scrollWidth > this.$.table.offsetWidth) {
        const frozenRect = cellFrozenToEnd.getBoundingClientRect();
        const offset = eventX - (isRTL ? frozenRect.right : frozenRect.left);
        if (isRTL && offset <= 0 || !isRTL && offset >= 0) {
          this.$.table.scrollLeft += offset;
        }
      }
      if (e.detail.state === "end") {
        this.$.scroller.toggleAttribute("column-resizing", false);
        this.dispatchEvent(new CustomEvent("column-resize", {
          detail: { resizedColumn: column }
        }));
      }
      this._resizeHandler();
    }
  }
};

// node_modules/@vaadin/component-base/src/data-provider-controller/cache.js
class Cache {
  context;
  pageSize;
  items = [];
  pendingRequests = {};
  #subCacheByIndex = {};
  #size = 0;
  #flatSize = 0;
  constructor(context, pageSize, size, parentCache, parentCacheIndex) {
    this.context = context;
    this.pageSize = pageSize;
    this.size = size;
    this.parentCache = parentCache;
    this.parentCacheIndex = parentCacheIndex;
    this.#flatSize = size || 0;
  }
  get parentItem() {
    return this.parentCache && this.parentCache.items[this.parentCacheIndex];
  }
  get subCaches() {
    return Object.values(this.#subCacheByIndex);
  }
  get isLoading() {
    if (Object.keys(this.pendingRequests).length > 0) {
      return true;
    }
    return this.subCaches.some((subCache) => subCache.isLoading);
  }
  get flatSize() {
    return this.#flatSize;
  }
  get size() {
    return this.#size;
  }
  set size(size) {
    const oldSize = this.#size;
    if (oldSize === size) {
      return;
    }
    this.#size = size;
    if (this.context.placeholder !== undefined) {
      this.items.length = size || 0;
      for (let i = 0;i < size; i++) {
        this.items[i] ||= this.context.placeholder;
      }
    }
    if (this.items.length > size) {
      this.items.length = size || 0;
    }
    Object.keys(this.pendingRequests).forEach((page) => {
      const startIndex = parseInt(page) * this.pageSize;
      if (startIndex >= this.size || 0) {
        delete this.pendingRequests[page];
      }
    });
  }
  recalculateFlatSize() {
    this.#flatSize = !this.parentItem || this.context.isExpanded(this.parentItem) ? this.size + this.subCaches.reduce((total, subCache) => {
      subCache.recalculateFlatSize();
      return total + subCache.flatSize;
    }, 0) : 0;
  }
  setPage(page, items) {
    const startIndex = page * this.pageSize;
    items.forEach((item, i) => {
      const itemIndex = startIndex + i;
      if (this.size === undefined || itemIndex < this.size) {
        this.items[itemIndex] = item;
      }
    });
  }
  getSubCache(index) {
    return this.#subCacheByIndex[index];
  }
  removeSubCache(index) {
    delete this.#subCacheByIndex[index];
  }
  removeSubCaches() {
    this.#subCacheByIndex = {};
  }
  createSubCache(index) {
    const subCache = new Cache(this.context, this.pageSize, 0, this, index);
    this.#subCacheByIndex[index] = subCache;
    return subCache;
  }
  getFlatIndex(index) {
    const clampedIndex = Math.max(0, Math.min(this.size - 1, index));
    return this.subCaches.reduce((prev, subCache) => {
      const index2 = subCache.parentCacheIndex;
      return clampedIndex > index2 ? prev + subCache.flatSize : prev;
    }, clampedIndex);
  }
}

// node_modules/@vaadin/component-base/src/data-provider-controller/helpers.js
function getFlatIndexContext(cache2, flatIndex, level = 0) {
  let levelIndex = flatIndex;
  for (const subCache of cache2.subCaches) {
    const index = subCache.parentCacheIndex;
    if (levelIndex <= index) {
      break;
    } else if (levelIndex <= index + subCache.flatSize) {
      return getFlatIndexContext(subCache, levelIndex - index - 1, level + 1);
    }
    levelIndex -= subCache.flatSize;
  }
  return {
    cache: cache2,
    item: cache2.items[levelIndex],
    index: levelIndex,
    page: Math.floor(levelIndex / cache2.pageSize),
    level
  };
}
function getItemContext({ getItemId }, cache2, targetItem, level = 0, levelFlatIndex = 0) {
  for (let index = 0;index < cache2.items.length; index++) {
    const item = cache2.items[index];
    if (!!item && getItemId(item) === getItemId(targetItem)) {
      return {
        cache: cache2,
        level,
        item,
        index,
        page: Math.floor(index / cache2.pageSize),
        subCache: cache2.getSubCache(index),
        flatIndex: levelFlatIndex + cache2.getFlatIndex(index)
      };
    }
  }
  for (const subCache of cache2.subCaches) {
    const parentItemFlatIndex = levelFlatIndex + cache2.getFlatIndex(subCache.parentCacheIndex);
    const result = getItemContext({ getItemId }, subCache, targetItem, level + 1, parentItemFlatIndex + 1);
    if (result) {
      return result;
    }
  }
}
function getFlatIndexByPath(cache2, [levelIndex, ...subIndexes], flatIndex = 0) {
  if (levelIndex === Infinity) {
    levelIndex = cache2.size - 1;
  }
  const flatIndexOnLevel = cache2.getFlatIndex(levelIndex);
  const subCache = cache2.getSubCache(levelIndex);
  if (subCache && subCache.flatSize > 0 && subIndexes.length) {
    return getFlatIndexByPath(subCache, subIndexes, flatIndex + flatIndexOnLevel + 1);
  }
  return flatIndex + flatIndexOnLevel;
}

// node_modules/@vaadin/component-base/src/data-provider-controller/data-provider-controller.js
class DataProviderController extends EventTarget {
  host;
  dataProvider;
  dataProviderParams;
  pageSize;
  isExpanded;
  getItemId;
  rootCache;
  placeholder;
  isPlaceholder;
  constructor(host, { size, pageSize, isExpanded, getItemId, isPlaceholder, placeholder, dataProvider, dataProviderParams }) {
    super();
    this.host = host;
    this.pageSize = pageSize;
    this.getItemId = getItemId;
    this.isExpanded = isExpanded;
    this.placeholder = placeholder;
    this.isPlaceholder = isPlaceholder;
    this.dataProvider = dataProvider;
    this.dataProviderParams = dataProviderParams;
    this.rootCache = this.#createRootCache(size);
  }
  get flatSize() {
    return this.rootCache.flatSize;
  }
  get #cacheContext() {
    return {
      isExpanded: this.isExpanded,
      placeholder: this.placeholder
    };
  }
  isLoading() {
    return this.rootCache.isLoading;
  }
  setPageSize(pageSize) {
    this.pageSize = pageSize;
    this.clearCache();
  }
  setDataProvider(dataProvider) {
    this.dataProvider = dataProvider;
    this.clearCache();
  }
  recalculateFlatSize() {
    this.rootCache.recalculateFlatSize();
  }
  clearCache() {
    this.rootCache = this.#createRootCache(this.rootCache.size);
  }
  getFlatIndexContext(flatIndex) {
    return getFlatIndexContext(this.rootCache, flatIndex);
  }
  getItemContext(item) {
    return getItemContext({ getItemId: this.getItemId }, this.rootCache, item);
  }
  getFlatIndexByPath(path) {
    return getFlatIndexByPath(this.rootCache, path);
  }
  ensureFlatIndexLoaded(flatIndex) {
    const { cache: cache2, page, item } = this.getFlatIndexContext(flatIndex);
    if (!this.#isItemLoaded(item)) {
      this.#loadCachePage(cache2, page);
    }
  }
  ensureFlatIndexHierarchy(flatIndex) {
    const { cache: cache2, item, index } = this.getFlatIndexContext(flatIndex);
    if (this.#isItemLoaded(item) && this.isExpanded(item) && !cache2.getSubCache(index)) {
      const subCache = cache2.createSubCache(index);
      this.#loadCachePage(subCache, 0);
    }
  }
  loadFirstPage() {
    this.#loadCachePage(this.rootCache, 0);
  }
  _shouldLoadCachePage(_cache, _page) {
    return true;
  }
  #createRootCache(size) {
    return new Cache(this.#cacheContext, this.pageSize, size);
  }
  #loadCachePage(cache2, page) {
    if (!this.dataProvider || cache2.pendingRequests[page] || !this._shouldLoadCachePage(cache2, page)) {
      return;
    }
    let params = {
      page,
      pageSize: this.pageSize,
      parentItem: cache2.parentItem
    };
    if (this.dataProviderParams) {
      params = { ...params, ...this.dataProviderParams() };
    }
    const callback = (items, size) => {
      if (cache2.pendingRequests[page] !== callback) {
        return;
      }
      if (size !== undefined) {
        cache2.size = size;
      } else if (params.parentItem) {
        cache2.size = items.length;
      }
      cache2.setPage(page, items);
      this.recalculateFlatSize();
      this.dispatchEvent(new CustomEvent("page-received"));
      delete cache2.pendingRequests[page];
      this.dispatchEvent(new CustomEvent("page-loaded"));
    };
    cache2.pendingRequests[page] = callback;
    this.dispatchEvent(new CustomEvent("page-requested"));
    this.dataProvider(params, callback);
  }
  #isItemLoaded(item) {
    if (this.isPlaceholder) {
      return !this.isPlaceholder(item);
    } else if (this.placeholder) {
      return item !== this.placeholder;
    }
    return !!item;
  }
}

// node_modules/@vaadin/grid/src/vaadin-grid-data-provider-mixin.js
var DataProviderMixin = (superClass) => class DataProviderMixin2 extends superClass {
  static get properties() {
    return {
      size: {
        type: Number,
        notify: true,
        sync: true
      },
      _flatSize: {
        type: Number,
        sync: true
      },
      pageSize: {
        type: Number,
        value: 50,
        observer: "_pageSizeChanged",
        sync: true
      },
      dataProvider: {
        type: Object,
        notify: true,
        observer: "_dataProviderChanged",
        sync: true
      },
      loading: {
        type: Boolean,
        notify: true,
        readOnly: true,
        reflectToAttribute: true
      },
      _hasData: {
        type: Boolean,
        value: false,
        sync: true
      },
      itemHasChildrenPath: {
        type: String,
        value: "children",
        observer: "__itemHasChildrenPathChanged",
        sync: true
      },
      itemIdPath: {
        type: String,
        value: null,
        sync: true
      },
      expandedItems: {
        type: Object,
        notify: true,
        value: () => [],
        sync: true
      },
      __expandedKeys: {
        type: Object,
        computed: "__computeExpandedKeys(itemIdPath, expandedItems)"
      }
    };
  }
  static get observers() {
    return ["_sizeChanged(size)", "_expandedItemsChanged(expandedItems)"];
  }
  constructor() {
    super();
    this._dataProviderController = new DataProviderController(this, {
      size: this.size || 0,
      pageSize: this.pageSize,
      getItemId: this.getItemId.bind(this),
      isExpanded: this._isExpanded.bind(this),
      dataProvider: this.dataProvider ? this.dataProvider.bind(this) : null,
      dataProviderParams: () => {
        return {
          sortOrders: this._mapSorters(),
          filters: this._mapFilters()
        };
      }
    });
    this._dataProviderController.addEventListener("page-requested", this._onDataProviderPageRequested.bind(this));
    this._dataProviderController.addEventListener("page-received", this._onDataProviderPageReceived.bind(this));
    this._dataProviderController.addEventListener("page-loaded", this._onDataProviderPageLoaded.bind(this));
  }
  _sizeChanged(size) {
    this._dataProviderController.rootCache.size = size;
    this._dataProviderController.recalculateFlatSize();
    this._flatSize = this._dataProviderController.flatSize;
  }
  __itemHasChildrenPathChanged(value, oldValue) {
    if (!oldValue && value === "children") {
      return;
    }
    this.requestContentUpdate();
  }
  __getRowLevel(row) {
    const { level } = this._dataProviderController.getFlatIndexContext(row.index);
    return level;
  }
  __getRowItem(row) {
    const { item } = this._dataProviderController.getFlatIndexContext(row.index);
    return item;
  }
  __ensureRowItem(row) {
    this._dataProviderController.ensureFlatIndexLoaded(row.index);
  }
  __ensureRowHierarchy(row) {
    this._dataProviderController.ensureFlatIndexHierarchy(row.index);
  }
  getItemId(item) {
    return this.itemIdPath ? get(this.itemIdPath, item) : item;
  }
  _isExpanded(item) {
    return this.__expandedKeys && this.__expandedKeys.has(this.getItemId(item));
  }
  _hasChildren(item) {
    return this.itemHasChildrenPath && item && !!get(this.itemHasChildrenPath, item);
  }
  _expandedItemsChanged() {
    this._dataProviderController.recalculateFlatSize();
    this._flatSize = this._dataProviderController.flatSize;
    this.__updateVisibleRows();
  }
  __computeExpandedKeys(_itemIdPath, expandedItems) {
    const expanded = expandedItems || [];
    const expandedKeys = new Set;
    expanded.forEach((item) => {
      expandedKeys.add(this.getItemId(item));
    });
    return expandedKeys;
  }
  expandItem(item) {
    if (!this._isExpanded(item)) {
      this.expandedItems = [...this.expandedItems, item];
    }
  }
  collapseItem(item) {
    if (this._isExpanded(item)) {
      this.expandedItems = this.expandedItems.filter((i) => !this._itemsEqual(i, item));
    }
  }
  _onDataProviderPageRequested() {
    this._setLoading(true);
  }
  _onDataProviderPageReceived() {
    if (this._flatSize !== this._dataProviderController.flatSize) {
      this._shouldLoadAllRenderedRowsAfterPageLoad = true;
      this._flatSize = this._dataProviderController.flatSize;
    }
    this._getRenderedRows().forEach((row) => this.__ensureRowHierarchy(row));
    this._hasData = true;
  }
  _onDataProviderPageLoaded() {
    this._debouncerApplyCachedData = Debouncer.debounce(this._debouncerApplyCachedData, timeOut.after(0), () => {
      this._setLoading(false);
      const shouldLoadAllRenderedRowsAfterPageLoad = this._shouldLoadAllRenderedRowsAfterPageLoad;
      this._shouldLoadAllRenderedRowsAfterPageLoad = false;
      this._getRenderedRows().forEach((row) => {
        this.__updateRow(row);
        if (shouldLoadAllRenderedRowsAfterPageLoad) {
          this.__ensureRowItem(row);
        }
      });
      this.__scrollToPendingIndexes();
      this.__dispatchPendingBodyCellFocus();
    });
    if (!this._dataProviderController.isLoading()) {
      this._debouncerApplyCachedData.flush();
    }
  }
  __debounceClearCache() {
    this.__clearCacheDebouncer = Debouncer.debounce(this.__clearCacheDebouncer, microTask, () => this.clearCache());
  }
  clearCache() {
    this._dataProviderController.clearCache();
    this._dataProviderController.rootCache.size = this.size || 0;
    this._dataProviderController.recalculateFlatSize();
    this._hasData = false;
    this.__updateVisibleRows();
    if (!this.__virtualizer || !this.__virtualizer.size) {
      this._dataProviderController.loadFirstPage();
    }
  }
  _pageSizeChanged(pageSize, oldPageSize) {
    this._dataProviderController.setPageSize(pageSize);
    if (oldPageSize !== undefined && pageSize !== oldPageSize) {
      this.clearCache();
    }
  }
  _checkSize() {
    if (this.size === undefined && this._flatSize === 0) {
      console.warn("The <vaadin-grid> needs the total number of items in" + " order to display rows, which you can specify either by setting" + " the `size` property, or by providing it to the second argument" + " of the `dataProvider` function `callback` call.");
    }
  }
  _dataProviderChanged(dataProvider, oldDataProvider) {
    this._dataProviderController.setDataProvider(dataProvider ? dataProvider.bind(this) : null);
    if (oldDataProvider !== undefined) {
      this.clearCache();
    }
    this._ensureFirstPageLoaded();
    this._debouncerCheckSize = Debouncer.debounce(this._debouncerCheckSize, timeOut.after(2000), this._checkSize.bind(this));
  }
  _ensureFirstPageLoaded() {
    if (!this._hasData) {
      this._dataProviderController.loadFirstPage();
    }
  }
  _itemsEqual(item1, item2) {
    return this.getItemId(item1) === this.getItemId(item2);
  }
  _getItemIndexInArray(item, array) {
    let result = -1;
    array.forEach((i, idx) => {
      if (this._itemsEqual(i, item)) {
        result = idx;
      }
    });
    return result;
  }
  scrollToIndex(...indexes) {
    if (!this.__virtualizer || !this.clientHeight || !this._columnTree) {
      this.__pendingScrollToIndexes = indexes;
      return;
    }
    let targetIndex;
    while (targetIndex !== (targetIndex = this._dataProviderController.getFlatIndexByPath(indexes))) {
      this._scrollToFlatIndex(targetIndex);
    }
    if (this._dataProviderController.isLoading()) {
      this.__pendingScrollToIndexes = indexes;
    }
  }
  __scrollToPendingIndexes() {
    if (this.__pendingScrollToIndexes && this.$.items.children.length) {
      const indexes = this.__pendingScrollToIndexes;
      delete this.__pendingScrollToIndexes;
      this.scrollToIndex(...indexes);
    }
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-drag-and-drop-mixin.js
var DropMode = {
  BETWEEN: "between",
  ON_TOP: "on-top",
  ON_TOP_OR_BETWEEN: "on-top-or-between",
  ON_GRID: "on-grid"
};
var DropLocation = {
  ON_TOP: "on-top",
  ABOVE: "above",
  BELOW: "below",
  EMPTY: "empty"
};
var DragAndDropMixin = (superClass) => class DragAndDropMixin2 extends superClass {
  static get properties() {
    return {
      dropMode: {
        type: String,
        sync: true
      },
      rowsDraggable: {
        type: Boolean,
        sync: true
      },
      dragFilter: {
        type: Function,
        sync: true
      },
      dropFilter: {
        type: Function,
        sync: true
      },
      __dndAutoScrollThreshold: {
        value: 50
      },
      __draggedItems: {
        value: () => []
      }
    };
  }
  static get observers() {
    return ["_dragDropAccessChanged(rowsDraggable, dropMode, dragFilter, dropFilter, loading)"];
  }
  constructor() {
    super();
    this.__onDocumentDragStart = this.__onDocumentDragStart.bind(this);
  }
  ready() {
    super.ready();
    this.$.table.addEventListener("dragstart", this._onDragStart.bind(this));
    this.$.table.addEventListener("dragend", this._onDragEnd.bind(this));
    this.$.table.addEventListener("dragover", this._onDragOver.bind(this));
    this.$.table.addEventListener("dragleave", this._onDragLeave.bind(this));
    this.$.table.addEventListener("drop", this._onDrop.bind(this));
    this.$.table.addEventListener("dragenter", (e) => {
      if (this.dropMode) {
        e.preventDefault();
        e.stopPropagation();
      }
    });
  }
  connectedCallback() {
    super.connectedCallback();
    document.addEventListener("dragstart", this.__onDocumentDragStart, { capture: true });
  }
  disconnectedCallback() {
    super.disconnectedCallback();
    document.removeEventListener("dragstart", this.__onDocumentDragStart, { capture: true });
  }
  _onDragStart(e) {
    if (this.rowsDraggable) {
      let row = e.target;
      if (row.localName === "vaadin-grid-cell-content") {
        row = row.assignedSlot.parentNode.parentNode;
      }
      if (row.parentNode !== this.$.items) {
        return;
      }
      e.stopPropagation();
      this.toggleAttribute("dragging-rows", true);
      if (this._safari) {
        const transform = row.style.transform;
        row.style.top = /translateY\((.*)\)/u.exec(transform)[1];
        row.style.transform = "none";
        requestAnimationFrame(() => {
          row.style.top = "";
          row.style.transform = transform;
        });
      }
      const rowRect = row.getBoundingClientRect();
      e.dataTransfer.setDragImage(row, e.clientX - rowRect.left, e.clientY - rowRect.top);
      let rows = [row];
      if (this._isSelected(row._item)) {
        rows = this.__getViewportRows().filter((row2) => this._isSelected(row2._item)).filter((row2) => !this.dragFilter || this.dragFilter(this.__getRowModel(row2)));
      }
      this.__draggedItems = rows.map((row2) => row2._item);
      e.dataTransfer.setData("text", this.__formatDefaultTransferData(rows));
      updateBooleanRowStates(row, { dragstart: rows.length > 1 ? `${rows.length}` : "" });
      this.style.setProperty("--_grid-drag-start-x", `${e.clientX - rowRect.left + 20}px`);
      this.style.setProperty("--_grid-drag-start-y", `${e.clientY - rowRect.top + 10}px`);
      requestAnimationFrame(() => {
        updateBooleanRowStates(row, { dragstart: false });
        this.style.setProperty("--_grid-drag-start-x", "");
        this.style.setProperty("--_grid-drag-start-y", "");
        this.requestContentUpdate();
      });
      const event = new CustomEvent("grid-dragstart", {
        detail: {
          draggedItems: [...this.__draggedItems],
          setDragData: (type, data) => e.dataTransfer.setData(type, data),
          setDraggedItemsCount: (count) => row.setAttribute("dragstart", count)
        }
      });
      event.originalEvent = e;
      this.dispatchEvent(event);
    }
  }
  _onDragEnd(e) {
    this.toggleAttribute("dragging-rows", false);
    e.stopPropagation();
    const event = new CustomEvent("grid-dragend");
    event.originalEvent = e;
    this.dispatchEvent(event);
    this.__draggedItems = [];
    this.requestContentUpdate();
  }
  _onDragLeave(e) {
    if (!this.dropMode) {
      return;
    }
    e.stopPropagation();
    this._clearDragStyles();
  }
  _onDragOver(e) {
    if (this.dropMode) {
      this._dropLocation = undefined;
      this._dragOverItem = undefined;
      if (this.__dndAutoScroll(e.clientY)) {
        this._clearDragStyles();
        return;
      }
      let row = e.composedPath().find((node) => node.localName === "tr");
      this.__updateRowScrollPositionProperty(row);
      if (!this._flatSize || this.dropMode === DropMode.ON_GRID) {
        this._dropLocation = DropLocation.EMPTY;
      } else if (!row || row.parentNode !== this.$.items) {
        if (row) {
          return;
        } else if (this.dropMode === DropMode.BETWEEN || this.dropMode === DropMode.ON_TOP_OR_BETWEEN) {
          row = Array.from(this.$.items.children).filter((row2) => !row2.hidden).pop();
          this._dropLocation = DropLocation.BELOW;
        } else {
          return;
        }
      } else {
        const rowRect = row.getBoundingClientRect();
        this._dropLocation = DropLocation.ON_TOP;
        if (this.dropMode === DropMode.BETWEEN) {
          const dropAbove = e.clientY - rowRect.top < rowRect.bottom - e.clientY;
          this._dropLocation = dropAbove ? DropLocation.ABOVE : DropLocation.BELOW;
        } else if (this.dropMode === DropMode.ON_TOP_OR_BETWEEN) {
          if (e.clientY - rowRect.top < rowRect.height / 3) {
            this._dropLocation = DropLocation.ABOVE;
          } else if (e.clientY - rowRect.top > rowRect.height / 3 * 2) {
            this._dropLocation = DropLocation.BELOW;
          }
        }
      }
      if (row && row.hasAttribute("drop-disabled")) {
        this._dropLocation = undefined;
        return;
      }
      e.stopPropagation();
      e.preventDefault();
      if (this._dropLocation === DropLocation.EMPTY) {
        this.toggleAttribute("dragover", true);
      } else if (row) {
        this._dragOverItem = row._item;
        if (row.getAttribute("dragover") !== this._dropLocation) {
          updateStringRowStates(row, { dragover: this._dropLocation });
        }
      } else {
        this._clearDragStyles();
      }
    }
  }
  __onDocumentDragStart(e) {
    if (e.target.contains(this)) {
      const elements = [e.target, this.$.items, this.$.scroller];
      const originalInlineStyles = elements.map((element) => element.style.cssText);
      if (this.$.table.scrollHeight > 20000) {
        this.$.scroller.style.display = "none";
      }
      if (isChrome) {
        e.target.style.willChange = "transform";
      }
      if (isSafari) {
        this.$.items.style.flexShrink = 1;
      }
      requestAnimationFrame(() => {
        elements.forEach((element, index) => {
          element.style.cssText = originalInlineStyles[index];
        });
      });
    }
  }
  __dndAutoScroll(clientY) {
    if (this.__dndAutoScrolling) {
      return true;
    }
    const headerBottom = this.$.header.getBoundingClientRect().bottom;
    const footerTop = this.$.footer.getBoundingClientRect().top;
    const topDiff = headerBottom - clientY + this.__dndAutoScrollThreshold;
    const bottomDiff = clientY - footerTop + this.__dndAutoScrollThreshold;
    let scrollTopDelta = 0;
    if (bottomDiff > 0) {
      scrollTopDelta = bottomDiff * 2;
    } else if (topDiff > 0) {
      scrollTopDelta = -topDiff * 2;
    }
    if (scrollTopDelta) {
      const scrollTop = this.$.table.scrollTop;
      this.$.table.scrollTop += scrollTopDelta;
      const scrollTopChanged = scrollTop !== this.$.table.scrollTop;
      if (scrollTopChanged) {
        this.__dndAutoScrolling = true;
        setTimeout(() => {
          this.__dndAutoScrolling = false;
        }, 20);
        return true;
      }
    }
  }
  __getViewportRows() {
    const headerBottom = this.$.header.getBoundingClientRect().bottom;
    const footerTop = this.$.footer.getBoundingClientRect().top;
    return Array.from(this.$.items.children).filter((row) => {
      const rowRect = row.getBoundingClientRect();
      return rowRect.bottom > headerBottom && rowRect.top < footerTop;
    });
  }
  _clearDragStyles() {
    this.removeAttribute("dragover");
    iterateChildren(this.$.items, (row) => {
      updateStringRowStates(row, { dragover: null });
    });
  }
  __updateDragSourceParts(row, model) {
    updateBooleanRowStates(row, { "drag-source": this.__draggedItems.includes(model.item) });
  }
  _onDrop(e) {
    if (this.dropMode && this._dropLocation) {
      e.stopPropagation();
      e.preventDefault();
      const dragData = e.dataTransfer.types && Array.from(e.dataTransfer.types).map((type) => {
        return {
          type,
          data: e.dataTransfer.getData(type)
        };
      });
      this._clearDragStyles();
      const event = new CustomEvent("grid-drop", {
        bubbles: e.bubbles,
        cancelable: e.cancelable,
        detail: {
          dropTargetItem: this._dragOverItem,
          dropLocation: this._dropLocation,
          dragData
        }
      });
      event.originalEvent = e;
      this.dispatchEvent(event);
    }
  }
  __formatDefaultTransferData(rows) {
    return rows.map((row) => {
      return Array.from(row.children).filter((cell) => !cell.hidden && !cell.part.contains("details-cell")).sort((a, b) => {
        return a._column._order > b._column._order ? 1 : -1;
      }).map((cell) => cell._content.textContent.trim()).filter((content) => content).join("\t");
    }).join(`
`);
  }
  _dragDropAccessChanged() {
    this.filterDragAndDrop();
  }
  filterDragAndDrop() {
    iterateChildren(this.$.items, (row) => {
      if (!row.hidden) {
        this._filterDragAndDrop(row, this.__getRowModel(row));
      }
    });
  }
  _filterDragAndDrop(row, model) {
    const loading = this.loading || row.hasAttribute("loading");
    const dragDisabled = !this.rowsDraggable || loading || this.dragFilter && !this.dragFilter(model);
    const dropDisabled = !this.dropMode || loading || this.dropFilter && !this.dropFilter(model);
    iterateRowCells(row, (cell) => {
      if (dragDisabled) {
        cell._content.removeAttribute("draggable");
      } else {
        cell._content.setAttribute("draggable", true);
      }
    });
    updateBooleanRowStates(row, {
      "drag-disabled": !!dragDisabled,
      "drop-disabled": !!dropDisabled
    });
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-dynamic-columns-mixin.js
function arrayEquals(arr1, arr2) {
  if (!arr1 || !arr2 || arr1.length !== arr2.length) {
    return false;
  }
  for (let i = 0, l = arr1.length;i < l; i++) {
    if (arr1[i] instanceof Array && arr2[i] instanceof Array) {
      if (!arrayEquals(arr1[i], arr2[i])) {
        return false;
      }
    } else if (arr1[i] !== arr2[i]) {
      return false;
    }
  }
  return true;
}
var DynamicColumnsMixin = (superClass) => class DynamicColumnsMixin2 extends superClass {
  static get properties() {
    return {
      _columnTree: {
        type: Object,
        sync: true
      }
    };
  }
  ready() {
    super.ready();
    this._addNodeObserver();
  }
  _hasColumnGroups(columns) {
    return columns.some((column) => column.localName === "vaadin-grid-column-group");
  }
  _getChildColumns(el) {
    return ColumnObserver.getColumns(el);
  }
  _flattenColumnGroups(columns) {
    return columns.map((col) => {
      if (col.localName === "vaadin-grid-column-group") {
        return this._getChildColumns(col);
      }
      return [col];
    }).reduce((prev, curr) => {
      return prev.concat(curr);
    }, []);
  }
  _getColumnTree() {
    const rootColumns = ColumnObserver.getColumns(this);
    const columnTree = [rootColumns];
    let c = rootColumns;
    while (this._hasColumnGroups(c)) {
      c = this._flattenColumnGroups(c);
      columnTree.push(c);
    }
    return columnTree;
  }
  _debounceUpdateColumnTree() {
    this.__updateColumnTreeDebouncer = Debouncer.debounce(this.__updateColumnTreeDebouncer, microTask, () => this._updateColumnTree());
  }
  _updateColumnTree() {
    const columnTree = this._getColumnTree();
    if (!arrayEquals(columnTree, this._columnTree)) {
      this._columnTree = columnTree;
    }
  }
  _addNodeObserver() {
    this._observer = new ColumnObserver(this, (_addedColumns, removedColumns) => {
      const allRemovedCells = removedColumns.flatMap((c) => c._allCells);
      const filterNotConnected = (element) => allRemovedCells.filter((cell) => cell && cell._content.contains(element)).length;
      this.__removeSorters(this._sorters.filter(filterNotConnected));
      this.__removeFilters(this._filters.filter(filterNotConnected));
      this._debounceUpdateColumnTree();
      this._debouncerCheckImports = Debouncer.debounce(this._debouncerCheckImports, timeOut.after(2000), this._checkImports.bind(this));
      this._ensureFirstPageLoaded();
    });
  }
  _checkImports() {
    [
      "vaadin-grid-column-group",
      "vaadin-grid-filter",
      "vaadin-grid-filter-column",
      "vaadin-grid-tree-toggle",
      "vaadin-grid-selection-column",
      "vaadin-grid-sort-column",
      "vaadin-grid-sorter"
    ].forEach((elementName) => {
      const element = this.querySelector(elementName);
      if (element && !customElements.get(elementName)) {
        console.warn(`Make sure you have imported the required module for <${elementName}> element.`);
      }
    });
  }
  _updateFirstAndLastColumn() {
    Array.from(this.shadowRoot.querySelectorAll("tr")).forEach((row) => this._updateFirstAndLastColumnForRow(row));
  }
  _updateFirstAndLastColumnForRow(row) {
    Array.from(row.querySelectorAll('[part~="cell"]:not([part~="details-cell"])')).sort((a, b) => {
      return a._column._order - b._column._order;
    }).forEach((cell, cellIndex, children) => {
      updateCellState(cell, "first-column", cellIndex === 0);
      updateCellState(cell, "last-column", cellIndex === children.length - 1);
    });
  }
  _isColumnElement(node) {
    return node.nodeType === Node.ELEMENT_NODE && /\bcolumn\b/u.test(node.localName);
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-event-context-mixin.js
var EventContextMixin = (superClass) => class EventContextMixin2 extends superClass {
  getEventContext(event) {
    const context = {};
    const { cell } = this._getGridEventLocation(event);
    if (!cell) {
      return context;
    }
    context.section = ["body", "header", "footer", "details"].find((section) => cell.part.contains(`${section}-cell`));
    if (cell._column) {
      context.column = cell._column;
    }
    if (context.section === "body" || context.section === "details") {
      Object.assign(context, this.__getRowModel(cell.parentElement));
    }
    return context;
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-filter-mixin.js
var FilterMixin = (superClass) => class FilterMixin2 extends superClass {
  static get properties() {
    return {
      _filters: {
        type: Array,
        value: () => []
      }
    };
  }
  constructor() {
    super();
    this._filterChanged = this._filterChanged.bind(this);
    this.addEventListener("filter-changed", this._filterChanged);
  }
  _filterChanged(e) {
    e.stopPropagation();
    this.__addFilter(e.target);
    this.__applyFilters();
  }
  __removeFilters(filtersToRemove) {
    if (filtersToRemove.length === 0) {
      return;
    }
    this._filters = this._filters.filter((filter2) => filtersToRemove.indexOf(filter2) < 0);
    this.__applyFilters();
  }
  __addFilter(filter2) {
    const filterIndex = this._filters.indexOf(filter2);
    if (filterIndex === -1) {
      this._filters.push(filter2);
    }
  }
  __applyFilters() {
    if (this.dataProvider && this.isAttached) {
      this.clearCache();
    }
  }
  _mapFilters() {
    return this._filters.map((filter2) => {
      return {
        path: filter2.path,
        value: filter2.value
      };
    });
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-keyboard-navigation-mixin.js
function isRow(element) {
  return element instanceof HTMLTableRowElement;
}
function isCell(element) {
  return element instanceof HTMLTableCellElement;
}
function isDetailsCell(element) {
  return element.matches('[part~="details-cell"]');
}
var KeyboardNavigationMixin = (superClass) => class KeyboardNavigationMixin2 extends superClass {
  static get properties() {
    return {
      _headerFocusable: {
        type: Object,
        observer: "_focusableChanged",
        sync: true
      },
      _itemsFocusable: {
        type: Object,
        observer: "_focusableChanged",
        sync: true
      },
      _footerFocusable: {
        type: Object,
        observer: "_focusableChanged",
        sync: true
      },
      _navigatingIsHidden: Boolean,
      _focusedItemIndex: {
        type: Number,
        value: 0
      },
      _focusedColumnOrder: Number,
      _focusedCell: {
        type: Object,
        observer: "_focusedCellChanged",
        sync: true
      },
      interacting: {
        type: Boolean,
        value: false,
        reflectToAttribute: true,
        readOnly: true,
        observer: "_interactingChanged"
      }
    };
  }
  get __rowFocusMode() {
    return [this._headerFocusable, this._itemsFocusable, this._footerFocusable].some(isRow);
  }
  set __rowFocusMode(value) {
    ["_itemsFocusable", "_footerFocusable", "_headerFocusable"].forEach((prop) => {
      const focusable = this[prop];
      if (value) {
        const parent = focusable && focusable.parentElement;
        if (isCell(focusable)) {
          this[prop] = parent;
        } else if (isCell(parent)) {
          this[prop] = parent.parentElement;
        }
      } else if (!value && isRow(focusable)) {
        const cell = focusable.firstElementChild;
        this[prop] = cell._focusButton || cell;
      }
    });
  }
  get _visibleItemsCount() {
    return this._lastVisibleIndex - this._firstVisibleIndex - 1;
  }
  ready() {
    super.ready();
    if (this._ios || this._android) {
      return;
    }
    this.addEventListener("keydown", this._onKeyDown);
    this.addEventListener("keyup", this._onKeyUp);
    this.addEventListener("focusin", this._onFocusIn);
    this.addEventListener("focusout", this._onFocusOut);
    this.$.table.addEventListener("focusin", this._onContentFocusIn.bind(this));
    this.addEventListener("mousedown", () => {
      this.toggleAttribute("navigating", false);
      this._isMousedown = true;
      this._focusedColumnOrder = undefined;
    });
    this.addEventListener("mouseup", () => {
      this._isMousedown = false;
    });
  }
  _focusableChanged(focusable, oldFocusable) {
    if (oldFocusable) {
      oldFocusable.setAttribute("tabindex", "-1");
    }
    if (focusable) {
      this._updateGridSectionFocusTarget(focusable);
    }
  }
  _focusedCellChanged(focusedCell, oldFocusedCell) {
    if (oldFocusedCell) {
      updatePart(oldFocusedCell, "focused-cell", false);
    }
    if (focusedCell) {
      updatePart(focusedCell, "focused-cell", true);
    }
  }
  _interactingChanged() {
    this._updateGridSectionFocusTarget(this._headerFocusable);
    this._updateGridSectionFocusTarget(this._itemsFocusable);
    this._updateGridSectionFocusTarget(this._footerFocusable);
  }
  __updateItemsFocusable() {
    if (!this._itemsFocusable) {
      return;
    }
    const wasFocused = this.shadowRoot.activeElement === this._itemsFocusable;
    this._getRenderedRows().forEach((row) => {
      if (row.index === this._focusedItemIndex) {
        if (this.__rowFocusMode) {
          this._itemsFocusable = row;
        } else {
          let parent = this._itemsFocusable.parentElement;
          let cell = this._itemsFocusable;
          if (parent) {
            if (isCell(parent)) {
              cell = parent;
              parent = parent.parentElement;
            }
            const cellIndex = [...parent.children].indexOf(cell);
            this._itemsFocusable = this.__getFocusable(row, row.children[cellIndex]);
          }
        }
      }
    });
    if (wasFocused) {
      this._itemsFocusable.focus();
    }
  }
  _onKeyDown(e) {
    const key = e.key;
    let keyGroup;
    switch (key) {
      case "ArrowUp":
      case "ArrowDown":
      case "ArrowLeft":
      case "ArrowRight":
      case "PageUp":
      case "PageDown":
      case "Home":
      case "End":
        keyGroup = "Navigation";
        break;
      case "Enter":
      case "Escape":
      case "F2":
        keyGroup = "Interaction";
        break;
      case "Tab":
        keyGroup = "Tab";
        break;
      case " ":
        keyGroup = "Space";
        break;
      default:
        break;
    }
    this._detectInteracting(e);
    if (this.interacting && keyGroup !== "Interaction") {
      keyGroup = undefined;
    }
    if (keyGroup) {
      this[`_on${keyGroup}KeyDown`](e, key);
    }
  }
  __ensureFlatIndexInViewport(index) {
    const targetRowInDom = [...this.$.items.children].find((child) => child.index === index);
    if (!targetRowInDom) {
      this._scrollToFlatIndex(index);
    } else {
      this.__scrollIntoViewport(targetRowInDom);
    }
  }
  __isRowExpandable(row) {
    return this._hasChildren(row._item) && !this._isExpanded(row._item);
  }
  __isRowCollapsible(row) {
    return this._isExpanded(row._item);
  }
  _onNavigationKeyDown(e, key) {
    e.preventDefault();
    const isRTL = this.__isRTL;
    const activeRow = e.composedPath().find(isRow);
    const activeCell = e.composedPath().find(isCell);
    let dx = 0, dy = 0;
    switch (key) {
      case "ArrowRight":
        dx = isRTL ? -1 : 1;
        break;
      case "ArrowLeft":
        dx = isRTL ? 1 : -1;
        break;
      case "Home":
        if (this.__rowFocusMode) {
          dy = -Infinity;
        } else if (e.ctrlKey) {
          dy = -Infinity;
        } else {
          dx = -Infinity;
        }
        break;
      case "End":
        if (this.__rowFocusMode) {
          dy = Infinity;
        } else if (e.ctrlKey) {
          dy = Infinity;
        } else {
          dx = Infinity;
        }
        break;
      case "ArrowDown":
        dy = 1;
        break;
      case "ArrowUp":
        dy = -1;
        break;
      case "PageDown":
        if (this.$.items.contains(activeRow)) {
          const currentRowIndex = this.__getIndexInGroup(activeRow, this._focusedItemIndex);
          this._scrollToFlatIndex(currentRowIndex);
        }
        dy = this._visibleItemsCount;
        break;
      case "PageUp":
        dy = -this._visibleItemsCount;
        break;
      default:
        break;
    }
    if (this.__rowFocusMode && !activeRow || !this.__rowFocusMode && !activeCell) {
      return;
    }
    const forwardsKey = isRTL ? "ArrowLeft" : "ArrowRight";
    const backwardsKey = isRTL ? "ArrowRight" : "ArrowLeft";
    if (key === forwardsKey) {
      if (this.__rowFocusMode) {
        if (this.__isRowExpandable(activeRow)) {
          this.expandItem(activeRow._item);
          return;
        }
        this.__rowFocusMode = false;
        this._onCellNavigation(activeRow.firstElementChild, 0, 0);
        return;
      }
    } else if (key === backwardsKey) {
      if (this.__rowFocusMode) {
        if (this.__isRowCollapsible(activeRow)) {
          this.collapseItem(activeRow._item);
          return;
        }
      } else {
        const activeRowCells = [...activeRow.children].sort((a, b) => a._order - b._order);
        if (activeCell === activeRowCells[0] || isDetailsCell(activeCell)) {
          this.__rowFocusMode = true;
          this._onRowNavigation(activeRow, 0);
          return;
        }
      }
    }
    if (this.__rowFocusMode) {
      this._onRowNavigation(activeRow, dy);
    } else {
      this._onCellNavigation(activeCell, dx, dy);
    }
  }
  _onRowNavigation(activeRow, dy) {
    const { dstRow } = this.__navigateRows(dy, activeRow);
    if (dstRow) {
      dstRow.focus();
    }
  }
  __getIndexInGroup(row, bodyFallbackIndex) {
    const rowGroup = row.parentNode;
    if (rowGroup === this.$.items) {
      return bodyFallbackIndex !== undefined ? bodyFallbackIndex : row.index;
    }
    return [...rowGroup.children].indexOf(row);
  }
  __navigateRows(dy, activeRow, activeCell) {
    const currentRowIndex = this.__getIndexInGroup(activeRow, this._focusedItemIndex);
    const activeRowGroup = activeRow.parentNode;
    const maxRowIndex = (activeRowGroup === this.$.items ? this._flatSize : activeRowGroup.children.length) - 1;
    let dstRowIndex = Math.max(0, Math.min(currentRowIndex + dy, maxRowIndex));
    if (activeRowGroup !== this.$.items) {
      if (dstRowIndex > currentRowIndex) {
        while (dstRowIndex < maxRowIndex && activeRowGroup.children[dstRowIndex].hidden) {
          dstRowIndex += 1;
        }
      } else if (dstRowIndex < currentRowIndex) {
        while (dstRowIndex > 0 && activeRowGroup.children[dstRowIndex].hidden) {
          dstRowIndex -= 1;
        }
      }
      this.toggleAttribute("navigating", true);
      return { dstRow: activeRowGroup.children[dstRowIndex] };
    }
    let dstIsRowDetails = false;
    if (activeCell) {
      const isRowDetails = isDetailsCell(activeCell);
      if (activeRowGroup === this.$.items) {
        const item = activeRow._item;
        const { item: dstItem } = this._dataProviderController.getFlatIndexContext(dstRowIndex);
        if (isRowDetails) {
          dstIsRowDetails = dy === 0;
        } else {
          dstIsRowDetails = dy === 1 && this._isDetailsOpened(item) || dy === -1 && dstRowIndex !== currentRowIndex && this._isDetailsOpened(dstItem);
        }
        if (dstIsRowDetails !== isRowDetails && (dy === 1 && dstIsRowDetails || dy === -1 && !dstIsRowDetails)) {
          dstRowIndex = currentRowIndex;
        }
      }
    }
    this.__ensureFlatIndexInViewport(dstRowIndex);
    this._focusedItemIndex = dstRowIndex;
    this.toggleAttribute("navigating", true);
    return {
      dstRow: [...activeRowGroup.children].find((el) => !el.hidden && el.index === dstRowIndex),
      dstIsRowDetails
    };
  }
  _onCellNavigation(activeCell, dx, dy) {
    const activeRow = activeCell.parentNode;
    const { dstRow, dstIsRowDetails } = this.__navigateRows(dy, activeRow, activeCell);
    if (!dstRow) {
      return;
    }
    let columnIndex = [...activeRow.children].indexOf(activeCell);
    if (this.$.items.contains(activeCell)) {
      columnIndex = [...this.$.sizer.children].findIndex((sizerCell) => sizerCell._column === activeCell._column);
    }
    const isCurrentCellRowDetails = isDetailsCell(activeCell);
    const activeRowGroup = activeRow.parentNode;
    const currentRowIndex = this.__getIndexInGroup(activeRow, this._focusedItemIndex);
    if (this._focusedColumnOrder === undefined) {
      if (isCurrentCellRowDetails) {
        this._focusedColumnOrder = 0;
      } else {
        this._focusedColumnOrder = this._getColumns(activeRowGroup, currentRowIndex).filter((c) => !c.hidden)[columnIndex]._order;
      }
    }
    if (dstIsRowDetails) {
      const dstCell = [...dstRow.children].find(isDetailsCell);
      dstCell.focus();
    } else {
      const dstRowIndex = this.__getIndexInGroup(dstRow, this._focusedItemIndex);
      const dstColumns = this._getColumns(activeRowGroup, dstRowIndex).filter((c) => !c.hidden);
      const dstSortedColumnOrders = dstColumns.map((c) => c._order).sort((b, a) => b - a);
      const maxOrderedColumnIndex = dstSortedColumnOrders.length - 1;
      const orderedColumnIndex = dstSortedColumnOrders.indexOf(dstSortedColumnOrders.slice(0).sort((b, a) => Math.abs(b - this._focusedColumnOrder) - Math.abs(a - this._focusedColumnOrder))[0]);
      const dstOrderedColumnIndex = dy === 0 && isCurrentCellRowDetails ? orderedColumnIndex : Math.max(0, Math.min(orderedColumnIndex + dx, maxOrderedColumnIndex));
      if (dstOrderedColumnIndex !== orderedColumnIndex) {
        this._focusedColumnOrder = undefined;
      }
      const columnIndexByOrder = dstColumns.reduce((acc, col, i) => {
        acc[col._order] = i;
        return acc;
      }, {});
      const dstColumnIndex = columnIndexByOrder[dstSortedColumnOrders[dstOrderedColumnIndex]];
      let dstCell;
      if (this.$.items.contains(activeCell)) {
        const dstSizerCell = this.$.sizer.children[dstColumnIndex];
        if (this._lazyColumns) {
          if (!this.__isColumnInViewport(dstSizerCell._column)) {
            dstSizerCell.scrollIntoView();
          }
          this.__updateColumnsBodyContentHidden();
          this.__updateHorizontalScrollPosition();
        }
        dstCell = [...dstRow.children].find((cell) => cell._column === dstSizerCell._column);
        this._scrollHorizontallyToCell(dstCell);
      } else {
        dstCell = dstRow.children[dstColumnIndex];
        this._scrollHorizontallyToCell(dstCell);
      }
      dstCell.focus({ preventScroll: true });
    }
  }
  _onInteractionKeyDown(e, key) {
    const localTarget = e.composedPath()[0];
    const localTargetIsTextInput = localTarget.localName === "input" && !/^(button|checkbox|color|file|image|radio|range|reset|submit)$/iu.test(localTarget.type);
    let wantInteracting;
    switch (key) {
      case "Enter":
        wantInteracting = this.interacting ? !localTargetIsTextInput : true;
        break;
      case "Escape":
        wantInteracting = false;
        break;
      case "F2":
        wantInteracting = !this.interacting;
        break;
      default:
        break;
    }
    const { cell } = this._getGridEventLocation(e);
    if (this.interacting !== wantInteracting && cell !== null) {
      if (wantInteracting) {
        const focusTarget = cell._content.querySelector("[focus-target]") || [...cell._content.querySelectorAll("*")].find((node) => this._isFocusable(node));
        if (focusTarget) {
          e.preventDefault();
          focusTarget.focus();
          this._setInteracting(true);
          this.toggleAttribute("navigating", false);
        }
      } else {
        e.preventDefault();
        this._focusedColumnOrder = undefined;
        cell.focus();
        this._setInteracting(false);
        this.toggleAttribute("navigating", true);
      }
    }
    if (key === "Escape") {
      this._hideTooltip(true);
    }
  }
  _predictFocusStepTarget(srcElement, step) {
    const tabOrder = [
      this.$.table,
      this._headerFocusable,
      this.__emptyState ? this.$.emptystatecell : this._itemsFocusable,
      this._footerFocusable,
      this.$.focusexit
    ];
    let index = tabOrder.indexOf(srcElement);
    index += step;
    while (index >= 0 && index <= tabOrder.length - 1) {
      let rowElement = tabOrder[index];
      if (rowElement && !this.__rowFocusMode) {
        rowElement = tabOrder[index].parentNode;
      }
      if (!rowElement || rowElement.hidden) {
        index += step;
      } else {
        break;
      }
    }
    let focusStepTarget = tabOrder[index];
    if (focusStepTarget && !this.__isHorizontallyInViewport(focusStepTarget)) {
      const firstVisibleColumn = this._getColumnsInOrder().find((column) => this.__isColumnInViewport(column));
      if (firstVisibleColumn) {
        if (focusStepTarget === this._headerFocusable) {
          focusStepTarget = firstVisibleColumn._headerCell;
        } else if (focusStepTarget === this._itemsFocusable) {
          const rowIndex = focusStepTarget._column._cells.indexOf(focusStepTarget);
          focusStepTarget = firstVisibleColumn._cells[rowIndex];
        } else if (focusStepTarget === this._footerFocusable) {
          focusStepTarget = firstVisibleColumn._footerCell;
        }
      }
    }
    return focusStepTarget;
  }
  _onTabKeyDown(e) {
    let focusTarget = this._predictFocusStepTarget(e.composedPath()[0], e.shiftKey ? -1 : 1);
    if (!focusTarget) {
      return;
    }
    e.stopPropagation();
    if (focusTarget === this._itemsFocusable) {
      this.__ensureFlatIndexInViewport(this._focusedItemIndex);
      this.__updateItemsFocusable();
      focusTarget = this._itemsFocusable;
    }
    focusTarget.focus();
    if (focusTarget !== this.$.table && focusTarget !== this.$.focusexit) {
      e.preventDefault();
    }
    this.toggleAttribute("navigating", true);
  }
  _onSpaceKeyDown(e) {
    e.preventDefault();
    const element = e.composedPath()[0];
    const isElementRow = isRow(element);
    if (isElementRow || !element._content || !element._content.firstElementChild) {
      this.dispatchEvent(new CustomEvent(isElementRow ? "row-activate" : "cell-activate", {
        detail: {
          model: this.__getRowModel(isElementRow ? element : element.parentElement)
        }
      }));
    }
  }
  _onKeyUp(e) {
    if (!/^( |SpaceBar)$/u.test(e.key) || this.interacting) {
      return;
    }
    e.preventDefault();
    const cell = e.composedPath()[0];
    if (cell._content && cell._content.firstElementChild) {
      const wasNavigating = this.hasAttribute("navigating");
      cell._content.firstElementChild.dispatchEvent(new MouseEvent("click", {
        shiftKey: e.shiftKey,
        bubbles: true,
        composed: true,
        cancelable: true
      }));
      this.toggleAttribute("navigating", wasNavigating);
    }
  }
  _onFocusIn(e) {
    if (!this._isMousedown) {
      this.toggleAttribute("navigating", true);
    }
    const rootTarget = e.composedPath()[0];
    if (rootTarget === this.$.table || rootTarget === this.$.focusexit) {
      if (!this._isMousedown) {
        this._predictFocusStepTarget(rootTarget, rootTarget === this.$.table ? 1 : -1).focus();
      }
      this._setInteracting(false);
    } else {
      this._detectInteracting(e);
    }
  }
  _onFocusOut(e) {
    this.toggleAttribute("navigating", false);
    this._detectInteracting(e);
    this._hideTooltip();
    this._focusedCell = null;
  }
  _onContentFocusIn(e) {
    const { section, cell, row } = this._getGridEventLocation(e);
    if (!cell && !this.__rowFocusMode) {
      return;
    }
    this._detectInteracting(e);
    if (section && (cell || row)) {
      this._activeRowGroup = section;
      if (section === this.$.header) {
        this._headerFocusable = this.__getFocusable(row, cell);
      } else if (section === this.$.items) {
        this._itemsFocusable = this.__getFocusable(row, cell);
        this._focusedItemIndex = row.index;
      } else if (section === this.$.footer) {
        this._footerFocusable = this.__getFocusable(row, cell);
      }
      if (cell) {
        const context = this.getEventContext(e);
        this.__pendingBodyCellFocus = this.loading && context.section === "body";
        if (!this.__pendingBodyCellFocus && cell !== this.$.emptystatecell) {
          cell.dispatchEvent(new CustomEvent("cell-focus", { bubbles: true, composed: true, detail: { context } }));
        }
        this._focusedCell = cell._focusButton || cell;
        if (isKeyboardActive() && e.target === cell) {
          this._showTooltip(e);
        }
      } else {
        this._focusedCell = null;
      }
    }
  }
  __dispatchPendingBodyCellFocus() {
    if (this.__pendingBodyCellFocus && this.shadowRoot.activeElement === this._itemsFocusable) {
      this._itemsFocusable.dispatchEvent(new Event("focusin", { bubbles: true, composed: true }));
    }
  }
  __getFocusable(row, cell) {
    return this.__rowFocusMode ? row : cell._focusButton || cell;
  }
  _detectInteracting(e) {
    const isInteracting = e.composedPath().some((el) => el.localName === "slot" && this.shadowRoot.contains(el));
    this._setInteracting(isInteracting);
    this.__updateHorizontalScrollPosition();
  }
  _updateGridSectionFocusTarget(focusTarget) {
    if (!focusTarget) {
      return;
    }
    const section = this._getGridSectionFromFocusTarget(focusTarget);
    const isInteractingWithinActiveSection = this.interacting && section === this._activeRowGroup;
    focusTarget.tabIndex = isInteractingWithinActiveSection ? -1 : 0;
  }
  _preventScrollerRotatingCellFocus() {
    if (this._activeRowGroup !== this.$.items) {
      return;
    }
    this.__preventScrollerRotatingCellFocusDebouncer = Debouncer.debounce(this.__preventScrollerRotatingCellFocusDebouncer, animationFrame, () => {
      const isItemsRowGroupActive = this._activeRowGroup === this.$.items;
      const isFocusedItemRendered = this._getRenderedRows().some((row) => row.index === this._focusedItemIndex);
      if (isFocusedItemRendered) {
        this.__updateItemsFocusable();
        if (isItemsRowGroupActive && !this.__rowFocusMode) {
          this._focusedCell = this._itemsFocusable;
        }
        if (this._navigatingIsHidden) {
          this.toggleAttribute("navigating", true);
          this._navigatingIsHidden = false;
        }
      } else if (isItemsRowGroupActive) {
        this._focusedCell = null;
        if (this.hasAttribute("navigating")) {
          this._navigatingIsHidden = true;
          this.toggleAttribute("navigating", false);
        }
      }
    });
  }
  _getColumns(rowGroup, rowIndex) {
    let columnTreeLevel = this._columnTree.length - 1;
    if (rowGroup === this.$.header) {
      columnTreeLevel = rowIndex;
    } else if (rowGroup === this.$.footer) {
      columnTreeLevel = this._columnTree.length - 1 - rowIndex;
    }
    return this._columnTree[columnTreeLevel];
  }
  __isValidFocusable(element) {
    return this.$.table.contains(element) && element.offsetHeight;
  }
  _resetKeyboardNavigation() {
    if (!this.$ && this.performUpdate) {
      this.performUpdate();
    }
    ["header", "footer"].forEach((section) => {
      if (!this.__isValidFocusable(this[`_${section}Focusable`])) {
        const firstVisibleRow = [...this.$[section].children].find((row) => row.offsetHeight);
        const firstVisibleCell = firstVisibleRow ? [...firstVisibleRow.children].find((cell) => !cell.hidden) : null;
        if (firstVisibleRow && firstVisibleCell) {
          this[`_${section}Focusable`] = this.__getFocusable(firstVisibleRow, firstVisibleCell);
        }
      }
    });
    if (!this.__isValidFocusable(this._itemsFocusable) && this.$.items.firstElementChild) {
      const firstVisibleRow = this.__getFirstVisibleItem();
      const firstVisibleCell = firstVisibleRow ? [...firstVisibleRow.children].find((cell) => !cell.hidden) : null;
      if (firstVisibleCell && firstVisibleRow) {
        this._focusedColumnOrder = undefined;
        this._itemsFocusable = this.__getFocusable(firstVisibleRow, firstVisibleCell);
      }
    } else {
      this.__updateItemsFocusable();
    }
  }
  _scrollHorizontallyToCell(dstCell) {
    if (dstCell.hasAttribute("frozen") || dstCell.hasAttribute("frozen-to-end") || isDetailsCell(dstCell)) {
      return;
    }
    const dstCellRect = dstCell.getBoundingClientRect();
    const dstRow = dstCell.parentNode;
    const dstCellIndex = Array.from(dstRow.children).indexOf(dstCell);
    const tableRect = this.$.table.getBoundingClientRect();
    const scrollbarWidth = this.$.table.clientWidth - this.$.table.offsetWidth;
    let leftBoundary = tableRect.left - (this.__isRTL ? scrollbarWidth : 0);
    let rightBoundary = tableRect.right + (this.__isRTL ? 0 : scrollbarWidth);
    for (let i = dstCellIndex - 1;i >= 0; i--) {
      const cell = dstRow.children[i];
      if (cell.hasAttribute("hidden") || isDetailsCell(cell)) {
        continue;
      }
      if (cell.hasAttribute("frozen") || cell.hasAttribute("frozen-to-end")) {
        leftBoundary = cell.getBoundingClientRect().right;
        break;
      }
    }
    for (let i = dstCellIndex + 1;i < dstRow.children.length; i++) {
      const cell = dstRow.children[i];
      if (cell.hasAttribute("hidden") || isDetailsCell(cell)) {
        continue;
      }
      if (cell.hasAttribute("frozen") || cell.hasAttribute("frozen-to-end")) {
        rightBoundary = cell.getBoundingClientRect().left;
        break;
      }
    }
    if (dstCellRect.left < leftBoundary) {
      this.$.table.scrollLeft += dstCellRect.left - leftBoundary;
    }
    if (dstCellRect.right > rightBoundary) {
      this.$.table.scrollLeft += dstCellRect.right - rightBoundary;
    }
  }
  _getGridEventLocation(e) {
    const path = e.__composedPath || e.composedPath();
    const tableIndex = path.indexOf(this.$.table);
    const section = tableIndex >= 1 ? path[tableIndex - 1] : null;
    const row = tableIndex >= 2 ? path[tableIndex - 2] : null;
    const cell = tableIndex >= 3 ? path[tableIndex - 3] : null;
    return {
      section,
      row,
      cell
    };
  }
  _getGridSectionFromFocusTarget(focusTarget) {
    if (focusTarget === this._headerFocusable) {
      return this.$.header;
    }
    if (focusTarget === this._itemsFocusable) {
      return this.$.items;
    }
    if (focusTarget === this._footerFocusable) {
      return this.$.footer;
    }
    return null;
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-resize-mixin.js
var ResizeMixin = (superClass) => class extends superClass {
  static get properties() {
    return {
      __hostVisible: {
        type: Boolean,
        value: false
      },
      __tableRect: Object,
      __headerRect: Object,
      __itemsRect: Object,
      __footerRect: Object
    };
  }
  ready() {
    super.ready();
    const resizeObserver = new ResizeObserver((entries) => {
      const hostEntry = entries.findLast(({ target }) => target === this);
      if (hostEntry) {
        this.__hostVisible = this.checkVisibility();
      }
      const tableEntry = entries.findLast(({ target }) => target === this.$.table);
      if (tableEntry) {
        this.__tableRect = tableEntry.contentRect;
      }
      const headerEntry = entries.findLast(({ target }) => target === this.$.header);
      if (headerEntry) {
        this.__headerRect = headerEntry.contentRect;
      }
      const itemsEntry = entries.findLast(({ target }) => target === this.$.items);
      if (itemsEntry) {
        this.__itemsRect = itemsEntry.contentRect;
      }
      const footerEntry = entries.findLast(({ target }) => target === this.$.footer);
      if (footerEntry) {
        this.__footerRect = footerEntry.contentRect;
      }
    });
    resizeObserver.observe(this);
    resizeObserver.observe(this.$.table);
    resizeObserver.observe(this.$.header);
    resizeObserver.observe(this.$.items);
    resizeObserver.observe(this.$.footer);
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-row-details-mixin.js
var RowDetailsMixin = (superClass) => class RowDetailsMixin2 extends superClass {
  static get properties() {
    return {
      detailsOpenedItems: {
        type: Array,
        value: () => [],
        sync: true
      },
      rowDetailsRenderer: {
        type: Function,
        sync: true
      },
      _detailsCells: {
        type: Array
      }
    };
  }
  static get observers() {
    return [
      "_detailsOpenedItemsChanged(detailsOpenedItems, rowDetailsRenderer)",
      "_rowDetailsRendererChanged(rowDetailsRenderer)"
    ];
  }
  ready() {
    super.ready();
    this._detailsCellResizeObserver = new ResizeObserver((entries) => {
      entries.forEach(({ target: cell }) => {
        this._updateDetailsCellHeight(cell.parentElement);
      });
    });
  }
  _rowDetailsRendererChanged(rowDetailsRenderer) {
    if (!rowDetailsRenderer) {
      return;
    }
    if (this._columnTree) {
      iterateChildren(this.$.items, (row) => {
        if (!row.querySelector("[part~=details-cell]")) {
          this.__initRow(row, this._columnTree[this._columnTree.length - 1]);
          this.__updateRow(row);
        }
      });
    }
  }
  _detailsOpenedItemsChanged(_detailsOpenedItems, rowDetailsRenderer) {
    iterateChildren(this.$.items, (row) => {
      if (row.hasAttribute("details-opened")) {
        this.__updateRow(row);
        return;
      }
      if (rowDetailsRenderer && this._isDetailsOpened(row._item)) {
        this.__updateRow(row);
      }
    });
  }
  _configureDetailsCell(cell) {
    updatePart(cell, "cell", true);
    updatePart(cell, "details-cell", true);
    cell.toggleAttribute("frozen", true);
    this._detailsCellResizeObserver.observe(cell);
  }
  _toggleDetailsCell(row, detailsOpened) {
    const cell = row.querySelector('[part~="details-cell"]');
    if (!cell) {
      return;
    }
    cell.hidden = !detailsOpened;
    if (cell.hidden) {
      return;
    }
    if (this.rowDetailsRenderer) {
      cell._renderer = this.rowDetailsRenderer;
    }
  }
  _updateDetailsCellHeight(row) {
    const cell = row.querySelector('[part~="details-cell"]');
    if (!cell) {
      return;
    }
    this.__updateDetailsRowPadding(row, cell);
    requestAnimationFrame(() => this.__updateDetailsRowPadding(row, cell));
  }
  __updateDetailsRowPadding(row, cell) {
    if (cell.hidden) {
      row.style.removeProperty("padding-bottom");
    } else {
      row.style.setProperty("padding-bottom", `${cell.offsetHeight}px`);
    }
  }
  _updateDetailsCellHeights() {
    iterateChildren(this.$.items, (row) => {
      this._updateDetailsCellHeight(row);
    });
  }
  _isDetailsOpened(item) {
    return this.detailsOpenedItems && this._getItemIndexInArray(item, this.detailsOpenedItems) !== -1;
  }
  openItemDetails(item) {
    if (!this._isDetailsOpened(item)) {
      this.detailsOpenedItems = [...this.detailsOpenedItems, item];
    }
  }
  closeItemDetails(item) {
    if (this._isDetailsOpened(item)) {
      this.detailsOpenedItems = this.detailsOpenedItems.filter((i) => !this._itemsEqual(i, item));
    }
  }
};

// node_modules/@vaadin/component-base/src/dir-utils.js
function getNormalizedScrollLeft(element, direction) {
  const { scrollLeft } = element;
  if (direction !== "rtl") {
    return scrollLeft;
  }
  return element.scrollWidth - element.clientWidth + scrollLeft;
}

// node_modules/@vaadin/component-base/src/overflow-controller.js
class OverflowController {
  constructor(host, scrollTarget) {
    this.host = host;
    this.scrollTarget = scrollTarget || host;
    this.__boundOnScroll = this.__onScroll.bind(this);
  }
  hostConnected() {
    if (!this.initialized) {
      this.initialized = true;
      this.observe();
    }
  }
  observe() {
    const { host } = this;
    this.__resizeObserver = new ResizeObserver(() => {
      this.__debounceOverflow = Debouncer.debounce(this.__debounceOverflow, animationFrame, () => {
        this.__updateOverflow();
      });
    });
    this.__resizeObserver.observe(host);
    [...host.children].forEach((child) => {
      this.__resizeObserver.observe(child);
    });
    this.__childObserver = new MutationObserver((mutations) => {
      mutations.forEach(({ addedNodes, removedNodes }) => {
        addedNodes.forEach((node) => {
          if (node.nodeType === Node.ELEMENT_NODE) {
            this.__resizeObserver.observe(node);
          }
        });
        removedNodes.forEach((node) => {
          if (node.nodeType === Node.ELEMENT_NODE) {
            this.__resizeObserver.unobserve(node);
          }
        });
      });
      this.__updateOverflow();
    });
    this.__childObserver.observe(host, { childList: true });
    this.scrollTarget.addEventListener("scroll", this.__boundOnScroll);
    this.__updateOverflow();
  }
  __onScroll() {
    this.__updateOverflow();
  }
  __updateOverflow() {
    const target = this.scrollTarget;
    let overflow = "";
    if (target.scrollTop > 0) {
      overflow += " top";
    }
    if (Math.ceil(target.scrollTop) < Math.ceil(target.scrollHeight - target.clientHeight)) {
      overflow += " bottom";
    }
    const scrollLeft = Math.abs(target.scrollLeft);
    if (scrollLeft > 0) {
      overflow += " start";
    }
    if (Math.ceil(scrollLeft) < Math.ceil(target.scrollWidth - target.clientWidth)) {
      overflow += " end";
    }
    overflow = overflow.trim();
    if (overflow.length > 0 && this.host.getAttribute("overflow") !== overflow) {
      this.host.setAttribute("overflow", overflow);
    } else if (overflow.length === 0 && this.host.hasAttribute("overflow")) {
      this.host.removeAttribute("overflow");
    }
  }
}

// node_modules/@vaadin/grid/src/vaadin-grid-scroll-mixin.js
var timeouts = {
  SCROLLING: 500,
  UPDATE_CONTENT_VISIBILITY: 100
};
var ScrollMixin = (superClass) => class ScrollMixin2 extends superClass {
  static get properties() {
    return {
      columnRendering: {
        type: String,
        value: "eager",
        sync: true
      },
      _frozenCells: {
        type: Array,
        value: () => []
      },
      _frozenToEndCells: {
        type: Array,
        value: () => []
      }
    };
  }
  static get observers() {
    return ["__columnRenderingChanged(_columnTree, columnRendering)"];
  }
  get _scrollLeft() {
    return this.$.table.scrollLeft;
  }
  get _scrollTop() {
    return this.$.table.scrollTop;
  }
  set _scrollTop(top) {
    this.$.table.scrollTop = top;
  }
  get _lazyColumns() {
    return this.columnRendering === "lazy";
  }
  ready() {
    super.ready();
    this.scrollTarget = this.$.table;
    this.$.items.addEventListener("focusin", (e) => {
      const composedPath = e.composedPath();
      const row = composedPath[composedPath.indexOf(this.$.items) - 1];
      if (row) {
        if (!this._isMousedown) {
          const tableHeight = this.$.table.clientHeight;
          const headerHeight = this.$.header.clientHeight;
          const footerHeight = this.$.footer.clientHeight;
          const viewportHeight = tableHeight - headerHeight - footerHeight;
          const isRowLargerThanViewport = row.clientHeight > viewportHeight;
          const scrollTarget = isRowLargerThanViewport ? e.target : row;
          this.__scrollIntoViewport(scrollTarget);
        }
        if (!this.$.table.contains(e.relatedTarget)) {
          this.$.table.dispatchEvent(new CustomEvent("virtualizer-element-focused", { detail: { element: row } }));
        }
      }
    });
    this.$.table.addEventListener("scroll", () => this._afterScroll());
    this.__overflowController = new OverflowController(this, this.$.table);
    this.addController(this.__overflowController);
  }
  _scrollToFlatIndex(index) {
    index = Math.min(this._flatSize - 1, Math.max(0, index));
    this.__virtualizer.scrollToIndex(index);
    const rowElement = [...this.$.items.children].find((child) => child.index === index);
    this.__scrollIntoViewport(rowElement);
  }
  __scrollIntoViewport(element) {
    if (!element) {
      return;
    }
    const elementRect = element.getBoundingClientRect();
    const elementComputedStyle = getComputedStyle(element);
    const elementTop = elementRect.top + parseInt(elementComputedStyle.scrollMarginTop || 0);
    const elementBottom = elementRect.bottom + parseInt(elementComputedStyle.scrollMarginBottom || 0);
    const footerTop = this.$.footer.getBoundingClientRect().top;
    const headerBottom = this.$.header.getBoundingClientRect().bottom;
    if (elementBottom > footerTop) {
      this.$.table.scrollTop += elementBottom - footerTop;
    } else if (elementTop < headerBottom) {
      this.$.table.scrollTop -= headerBottom - elementTop;
    }
  }
  _scheduleScrolling() {
    if (!this._scrollingFrame) {
      this._scrollingFrame = requestAnimationFrame(() => this.$.scroller.toggleAttribute("scrolling", true));
    }
    this._debounceScrolling = Debouncer.debounce(this._debounceScrolling, timeOut.after(timeouts.SCROLLING), () => {
      cancelAnimationFrame(this._scrollingFrame);
      delete this._scrollingFrame;
      this.$.scroller.toggleAttribute("scrolling", false);
    });
  }
  _afterScroll() {
    this.__updateHorizontalScrollPosition();
    if (!this.hasAttribute("reordering")) {
      this._scheduleScrolling();
    }
    if (!this.hasAttribute("navigating")) {
      this._hideTooltip(true);
    }
    this._debounceColumnContentVisibility = Debouncer.debounce(this._debounceColumnContentVisibility, timeOut.after(timeouts.UPDATE_CONTENT_VISIBILITY), () => {
      if (this._lazyColumns && this.__cachedScrollLeft !== this._scrollLeft) {
        this.__cachedScrollLeft = this._scrollLeft;
        this.__updateColumnsBodyContentHidden();
      }
    });
  }
  __updateColumnsBodyContentHidden() {
    if (!this._columnTree || !this._areSizerCellsAssigned()) {
      return;
    }
    const columnsInOrder = this._getColumnsInOrder();
    let bodyContentHiddenChanged = false;
    columnsInOrder.forEach((column) => {
      const bodyContentHidden = this._lazyColumns && !this.__isColumnInViewport(column);
      if (column._bodyContentHidden !== bodyContentHidden) {
        bodyContentHiddenChanged = true;
        column._cells.forEach((cell) => {
          if (cell !== column._sizerCell) {
            if (bodyContentHidden) {
              cell.remove();
            } else if (cell.__parentRow) {
              const followingColumnCell = [...cell.__parentRow.children].find((child) => columnsInOrder.indexOf(child._column) > columnsInOrder.indexOf(column));
              cell.__parentRow.insertBefore(cell, followingColumnCell);
            }
          }
        });
      }
      column._bodyContentHidden = bodyContentHidden;
    });
    if (bodyContentHiddenChanged) {
      this._frozenCellsChanged();
    }
    if (this._lazyColumns) {
      const lastFrozenColumn = [...columnsInOrder].reverse().find((column) => column.frozen);
      const lastFrozenColumnEnd = this.__getColumnEnd(lastFrozenColumn);
      const firstVisibleColumn = columnsInOrder.find((column) => !column.frozen && !column._bodyContentHidden);
      this.__lazyColumnsStart = this.__getColumnStart(firstVisibleColumn) - lastFrozenColumnEnd;
      this.$.items.style.setProperty("--_grid-lazy-columns-start", `${this.__lazyColumnsStart}px`);
      this._resetKeyboardNavigation();
    }
  }
  __getColumnEnd(column) {
    if (!column) {
      return this.__isRTL ? this.$.table.clientWidth : 0;
    }
    return column._sizerCell.offsetLeft + (this.__isRTL ? 0 : column._sizerCell.offsetWidth);
  }
  __getColumnStart(column) {
    if (!column) {
      return this.__isRTL ? this.$.table.clientWidth : 0;
    }
    return column._sizerCell.offsetLeft + (this.__isRTL ? column._sizerCell.offsetWidth : 0);
  }
  __isColumnInViewport(column) {
    if (column.frozen || column.frozenToEnd) {
      return true;
    }
    return this.__isHorizontallyInViewport(column._sizerCell);
  }
  __isHorizontallyInViewport(element) {
    return element.offsetLeft + element.offsetWidth >= this._scrollLeft && element.offsetLeft <= this._scrollLeft + this.clientWidth;
  }
  __columnRenderingChanged(_columnTree, columnRendering) {
    if (columnRendering === "eager") {
      this.$.scroller.removeAttribute("column-rendering");
    } else {
      this.$.scroller.setAttribute("column-rendering", columnRendering);
    }
    this.__updateColumnsBodyContentHidden();
  }
  _frozenCellsChanged() {
    this._debouncerCacheElements = Debouncer.debounce(this._debouncerCacheElements, microTask, () => {
      Array.from(this.shadowRoot.querySelectorAll('[part~="cell"]')).forEach((cell) => {
        cell.style.transform = "";
      });
      this._frozenCells = Array.prototype.slice.call(this.$.table.querySelectorAll("[frozen]"));
      this._frozenToEndCells = Array.prototype.slice.call(this.$.table.querySelectorAll("[frozen-to-end]"));
      this.__updateHorizontalScrollPosition();
    });
    this._debounceUpdateFrozenColumn();
  }
  _debounceUpdateFrozenColumn() {
    this.__debounceUpdateFrozenColumn = Debouncer.debounce(this.__debounceUpdateFrozenColumn, microTask, () => this._updateFrozenColumn());
  }
  _updateFrozenColumn() {
    if (!this._columnTree) {
      return;
    }
    const columnsRow = this._columnTree[this._columnTree.length - 1].slice(0);
    columnsRow.sort((a, b) => {
      return a._order - b._order;
    });
    let lastFrozen;
    let firstFrozenToEnd;
    for (let i = 0;i < columnsRow.length; i++) {
      const col = columnsRow[i];
      col._lastFrozen = false;
      col._firstFrozenToEnd = false;
      if (firstFrozenToEnd === undefined && col.frozenToEnd && !col.hidden) {
        firstFrozenToEnd = i;
      }
      if (col.frozen && !col.hidden) {
        lastFrozen = i;
      }
    }
    if (lastFrozen !== undefined) {
      columnsRow[lastFrozen]._lastFrozen = true;
    }
    if (firstFrozenToEnd !== undefined) {
      columnsRow[firstFrozenToEnd]._firstFrozenToEnd = true;
    }
    this.__updateColumnsBodyContentHidden();
  }
  __updateHorizontalScrollPosition() {
    if (!this._columnTree) {
      return;
    }
    const scrollWidth = this.$.table.scrollWidth;
    const clientWidth = this.$.table.clientWidth;
    const scrollLeft = Math.max(0, this.$.table.scrollLeft);
    const normalizedScrollLeft = getNormalizedScrollLeft(this.$.table, this.getAttribute("dir"));
    const transform = `translate(${-scrollLeft}px, 0)`;
    this.$.header.style.transform = transform;
    this.$.footer.style.transform = transform;
    this.$.items.style.transform = transform;
    const x = this.__isRTL ? normalizedScrollLeft + clientWidth - scrollWidth : scrollLeft;
    this.__horizontalScrollPosition = x;
    const transformFrozen = `translate(${x}px, 0)`;
    this._frozenCells.forEach((cell) => {
      cell.style.transform = transformFrozen;
    });
    const remaining = this.__isRTL ? normalizedScrollLeft : scrollLeft + clientWidth - scrollWidth;
    const transformFrozenToEnd = `translate(${remaining}px, 0)`;
    let transformFrozenToEndBody = transformFrozenToEnd;
    if (this._lazyColumns && this._areSizerCellsAssigned()) {
      const columnsInOrder = this._getColumnsInOrder();
      const lastVisibleColumn = [...columnsInOrder].reverse().find((column) => !column.frozenToEnd && !column._bodyContentHidden);
      const lastVisibleColumnEnd = this.__getColumnEnd(lastVisibleColumn);
      const firstFrozenToEndColumn = columnsInOrder.find((column) => column.frozenToEnd);
      const firstFrozenToEndColumnStart = this.__getColumnStart(firstFrozenToEndColumn);
      const translateX = remaining + (firstFrozenToEndColumnStart - lastVisibleColumnEnd) + this.__lazyColumnsStart;
      transformFrozenToEndBody = `translate(${translateX}px, 0)`;
    }
    this._frozenToEndCells.forEach((cell) => {
      if (this.$.items.contains(cell)) {
        cell.style.transform = transformFrozenToEndBody;
      } else {
        cell.style.transform = transformFrozenToEnd;
      }
    });
    const focusedRow = this.shadowRoot.querySelector("[part~='row']:focus");
    if (focusedRow) {
      this.__updateRowScrollPositionProperty(focusedRow);
    }
    const lastHeaderRow = this.$.header.querySelector("[part~='last-header-row']");
    if (lastHeaderRow) {
      this.__updateRowScrollPositionProperty(lastHeaderRow);
    }
    const firstFooterRow = this.$.footer.querySelector("[part~='first-footer-row']");
    if (firstFooterRow) {
      this.__updateRowScrollPositionProperty(firstFooterRow);
    }
  }
  __updateRowScrollPositionProperty(row) {
    if (row instanceof HTMLTableRowElement === false) {
      return;
    }
    const newValue = `${this.__horizontalScrollPosition}px`;
    if (row.style.getPropertyValue("--_grid-horizontal-scroll-position") !== newValue) {
      row.style.setProperty("--_grid-horizontal-scroll-position", newValue);
    }
  }
  _areSizerCellsAssigned() {
    return this._getColumnsInOrder().every((column) => column._sizerCell);
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-selection-mixin.js
var SelectionMixin = (superClass) => class SelectionMixin2 extends superClass {
  static get properties() {
    return {
      selectedItems: {
        type: Object,
        notify: true,
        value: () => [],
        sync: true
      },
      isItemSelectable: {
        type: Function,
        notify: (() => true)()
      },
      __selectedKeys: {
        type: Object,
        computed: "__computeSelectedKeys(itemIdPath, selectedItems)"
      }
    };
  }
  static get observers() {
    return ["__selectedItemsChanged(itemIdPath, selectedItems, isItemSelectable)"];
  }
  _isSelected(item) {
    return this.__selectedKeys.has(this.getItemId(item));
  }
  __isItemSelectable(item) {
    if (!this.isItemSelectable || !item) {
      return true;
    }
    return this.isItemSelectable(item);
  }
  selectItem(item) {
    if (!this._isSelected(item)) {
      this.selectedItems = [...this.selectedItems, item];
    }
  }
  deselectItem(item) {
    if (this._isSelected(item)) {
      this.selectedItems = this.selectedItems.filter((i) => !this._itemsEqual(i, item));
    }
  }
  __selectedItemsChanged() {
    this.requestContentUpdate();
  }
  __computeSelectedKeys(_itemIdPath, selectedItems) {
    const selected = selectedItems || [];
    const selectedKeys = new Set;
    selected.forEach((item) => {
      selectedKeys.add(this.getItemId(item));
    });
    return selectedKeys;
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-sort-mixin.js
var defaultMultiSortPriority = "prepend";
var SortMixin = (superClass) => class SortMixin2 extends superClass {
  static get properties() {
    return {
      multiSort: {
        type: Boolean,
        value: false
      },
      multiSortPriority: {
        type: String,
        value: () => defaultMultiSortPriority
      },
      multiSortOnShiftClick: {
        type: Boolean,
        value: false
      },
      _sorters: {
        type: Array,
        value: () => []
      },
      _previousSorters: {
        type: Array,
        value: () => []
      }
    };
  }
  static setDefaultMultiSortPriority(priority) {
    defaultMultiSortPriority = ["append", "prepend"].includes(priority) ? priority : "prepend";
  }
  ready() {
    super.ready();
    this.addEventListener("sorter-changed", this._onSorterChanged);
  }
  _onSorterChanged(e) {
    const sorter = e.target;
    e.stopPropagation();
    sorter._grid = this;
    this.__updateSorter(sorter, e.detail.shiftClick, e.detail.fromSorterClick);
    this.__applySorters();
  }
  __removeSorters(sortersToRemove) {
    if (sortersToRemove.length === 0) {
      return;
    }
    this._sorters = this._sorters.filter((sorter) => !sortersToRemove.includes(sorter));
    this.__applySorters();
  }
  __updateSortOrders() {
    this._sorters.forEach((sorter) => {
      sorter._order = null;
    });
    const activeSorters = this._getActiveSorters();
    if (activeSorters.length > 1) {
      activeSorters.forEach((sorter, index) => {
        sorter._order = index;
      });
    }
  }
  __updateSorter(sorter, shiftClick, fromSorterClick) {
    if (!sorter.direction && !this._sorters.includes(sorter)) {
      return;
    }
    sorter._order = null;
    const restSorters = this._sorters.filter((s) => s !== sorter);
    if (this.multiSort && (!this.multiSortOnShiftClick || !fromSorterClick) || this.multiSortOnShiftClick && shiftClick) {
      if (this.multiSortPriority === "append") {
        this._sorters = [...restSorters, sorter];
      } else {
        this._sorters = [sorter, ...restSorters];
      }
    } else if (sorter.direction || this.multiSortOnShiftClick) {
      this._sorters = sorter.direction ? [sorter] : [];
      restSorters.forEach((sorter2) => {
        sorter2._order = null;
        sorter2.direction = null;
      });
    }
  }
  __applySorters() {
    this.__updateSortOrders();
    if (this.dataProvider && this.isAttached && JSON.stringify(this._previousSorters) !== JSON.stringify(this._mapSorters())) {
      this.__debounceClearCache();
    }
    this.__a11yUpdateSorters();
    this._previousSorters = this._mapSorters();
  }
  _getActiveSorters() {
    return this._sorters.filter((sorter) => sorter.direction && sorter.isConnected);
  }
  _mapSorters() {
    return this._getActiveSorters().map((sorter) => {
      return {
        path: sorter.path,
        direction: sorter.direction
      };
    });
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-styling-mixin.js
var StylingMixin = (superClass) => class StylingMixin2 extends superClass {
  static get properties() {
    return {
      cellPartNameGenerator: {
        type: Function,
        sync: true
      }
    };
  }
  static get observers() {
    return ["__cellPartNameGeneratorChanged(cellPartNameGenerator)"];
  }
  __cellPartNameGeneratorChanged() {
    this.generateCellPartNames();
  }
  generateCellPartNames() {
    iterateChildren(this.$.items, (row) => {
      if (!row.hidden) {
        this._generateCellPartNames(row, this.__getRowModel(row));
      }
    });
  }
  _generateCellPartNames(row, model) {
    iterateRowCells(row, (cell) => {
      if (cell.__generatedParts) {
        cell.__generatedParts.forEach((partName) => {
          updatePart(cell, partName, null);
        });
      }
      if (this.cellPartNameGenerator && !row.hasAttribute("loading")) {
        const result = this.cellPartNameGenerator(cell._column, model);
        cell.__generatedParts = result && result.split(" ").filter((partName) => partName.length > 0);
        if (cell.__generatedParts) {
          cell.__generatedParts.forEach((partName) => {
            updatePart(cell, partName, true);
          });
        }
      }
    });
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid-mixin.js
var GridMixin = (superClass) => class extends ColumnAutoWidthMixin(ArrayDataProviderMixin(DataProviderMixin(DynamicColumnsMixin(ActiveItemMixin(ScrollMixin(SelectionMixin(SortMixin(RowDetailsMixin(KeyboardNavigationMixin(A11yMixin(FilterMixin(ColumnReorderingMixin(ColumnResizingMixin(EventContextMixin(DragAndDropMixin(StylingMixin(TabindexMixin(ResizeMixin(superClass))))))))))))))))))) {
  static get observers() {
    return ["_columnTreeChanged(_columnTree)", "_flatSizeChanged(_flatSize, __virtualizer, _hasData, _columnTree)"];
  }
  static get properties() {
    return {
      _safari: {
        type: Boolean,
        value: isSafari
      },
      _ios: {
        type: Boolean,
        value: isIOS
      },
      _firefox: {
        type: Boolean,
        value: isFirefox
      },
      _android: {
        type: Boolean,
        value: isAndroid
      },
      _touchDevice: {
        type: Boolean,
        value: isTouch
      },
      allRowsVisible: {
        type: Boolean,
        value: false,
        reflectToAttribute: true
      },
      isAttached: {
        value: false
      },
      __gridElement: {
        type: Boolean,
        value: true
      },
      __hasEmptyStateContent: {
        type: Boolean,
        value: false
      },
      __emptyState: {
        type: Boolean,
        computed: "__computeEmptyState(_flatSize, __hasEmptyStateContent)"
      }
    };
  }
  get _firstVisibleIndex() {
    const firstVisibleItem = this.__getFirstVisibleItem();
    return firstVisibleItem ? firstVisibleItem.index : undefined;
  }
  get _lastVisibleIndex() {
    const lastVisibleItem = this.__getLastVisibleItem();
    return lastVisibleItem ? lastVisibleItem.index : undefined;
  }
  connectedCallback() {
    super.connectedCallback();
    this.isAttached = true;
    this.__virtualizer.hostConnected();
  }
  disconnectedCallback() {
    super.disconnectedCallback();
    this.isAttached = false;
    this._hideTooltip(true);
  }
  __getFirstVisibleItem() {
    return this._getRenderedRows().find((row) => this._isInViewport(row));
  }
  __getLastVisibleItem() {
    return this._getRenderedRows().reverse().find((row) => this._isInViewport(row));
  }
  _isInViewport(item) {
    const scrollTargetRect = this.$.table.getBoundingClientRect();
    const itemRect = item.getBoundingClientRect();
    const headerHeight = this.$.header.getBoundingClientRect().height;
    const footerHeight = this.$.footer.getBoundingClientRect().height;
    return itemRect.bottom > scrollTargetRect.top + headerHeight && itemRect.top < scrollTargetRect.bottom - footerHeight;
  }
  _getRenderedRows() {
    return Array.from(this.$.items.children).filter((item) => !item.hidden).sort((a, b) => a.index - b.index);
  }
  _getRowContainingNode(node) {
    const content = getClosestElement("vaadin-grid-cell-content", node);
    if (!content) {
      return;
    }
    const cell = content.assignedSlot.parentElement;
    return cell.parentElement;
  }
  _isItemAssignedToRow(item, row) {
    const model = this.__getRowModel(row);
    return this.getItemId(item) === this.getItemId(model.item);
  }
  ready() {
    super.ready();
    this.__virtualizer = new Virtualizer({
      createElements: this._createScrollerRows.bind(this),
      updateElement: this._updateScrollerItem.bind(this),
      scrollContainer: this.$.items,
      scrollTarget: this.$.table,
      reorderElements: true,
      __disableHeightPlaceholder: true
    });
    this._tooltipController = new TooltipController(this);
    this.addController(this._tooltipController);
    this._tooltipController.setManual(true);
    this.__emptyStateContentObserver = new SlotObserver(this.$.emptystateslot, ({ currentNodes }) => {
      this.$.emptystatecell._content = currentNodes[0];
      this.__hasEmptyStateContent = !!this.$.emptystatecell._content;
    });
  }
  updated(props) {
    super.updated(props);
    if (props.has("__hostVisible") && !props.get("__hostVisible")) {
      this._resetKeyboardNavigation();
      requestAnimationFrame(() => this.__scrollToPendingIndexes());
    }
    if (props.has("__headerRect") || props.has("__footerRect") || props.has("__itemsRect")) {
      setTimeout(() => this.__updateMinHeight());
    }
    if (props.has("__tableRect")) {
      setTimeout(() => this.__updateColumnsBodyContentHidden());
      this.__updateHorizontalScrollPosition();
    }
  }
  __getBodyCellCoordinates(cell) {
    if (this.$.items.contains(cell) && cell.localName === "td") {
      return {
        item: cell.parentElement._item,
        column: cell._column
      };
    }
  }
  __focusBodyCell({ item, column }) {
    const row = this._getRenderedRows().find((row2) => row2._item === item);
    const cell = row && [...row.children].find((cell2) => cell2._column === column);
    if (cell) {
      cell.focus();
    }
  }
  _focusFirstVisibleRow() {
    const row = this.__getFirstVisibleItem();
    this.__rowFocusMode = true;
    row.focus();
  }
  _flatSizeChanged(flatSize, virtualizer, hasData, columnTree) {
    if (virtualizer && hasData && columnTree) {
      const cell = this.shadowRoot.activeElement;
      const cellCoordinates = this.__getBodyCellCoordinates(cell);
      const previousSize = virtualizer.size || 0;
      virtualizer.size = flatSize;
      virtualizer.update(previousSize - 1, previousSize - 1);
      if (flatSize < previousSize) {
        virtualizer.update(flatSize - 1, flatSize - 1);
      }
      if (cellCoordinates && cell.parentElement.hidden) {
        this.__focusBodyCell(cellCoordinates);
      }
      this._resetKeyboardNavigation();
    }
  }
  _createScrollerRows(count) {
    const rows = [];
    for (let i = 0;i < count; i++) {
      const row = document.createElement("tr");
      row.setAttribute("role", "row");
      row.setAttribute("tabindex", "-1");
      updatePart(row, "row", true);
      updatePart(row, "body-row", true);
      if (this._columnTree) {
        this.__initRow(row, this._columnTree[this._columnTree.length - 1], "body", false, true);
      }
      rows.push(row);
    }
    if (this._columnTree) {
      this._columnTree[this._columnTree.length - 1].forEach((c) => {
        if (c.isConnected && c._cells) {
          c._cells = [...c._cells];
        }
      });
    }
    this.__afterCreateScrollerRowsDebouncer = Debouncer.debounce(this.__afterCreateScrollerRowsDebouncer, animationFrame, () => {
      this._afterScroll();
    });
    return rows;
  }
  _createCell(tagName, column) {
    const contentId = this._contentIndex = this._contentIndex + 1 || 0;
    const slotName = `vaadin-grid-cell-content-${contentId}`;
    const cellContent = document.createElement("vaadin-grid-cell-content");
    cellContent.setAttribute("slot", slotName);
    const cell = document.createElement(tagName);
    cell.id = slotName.replace("-content-", "-");
    cell.setAttribute("role", tagName === "td" ? "gridcell" : "columnheader");
    if (!isAndroid && !isIOS) {
      cell.addEventListener("mouseenter", (event) => {
        if (!this.$.scroller.hasAttribute("scrolling")) {
          this._showTooltip(event);
        }
      });
      cell.addEventListener("mouseleave", () => {
        this._hideTooltip();
      });
      cell.addEventListener("mousedown", () => {
        this._hideTooltip(true);
      });
    }
    const slot = document.createElement("slot");
    slot.setAttribute("name", slotName);
    if (column && column._focusButtonMode) {
      const div = document.createElement("div");
      div.setAttribute("role", "button");
      div.setAttribute("tabindex", "-1");
      cell.appendChild(div);
      cell._focusButton = div;
      cell.focus = function(options) {
        cell._focusButton.focus(options);
      };
      div.appendChild(slot);
    } else {
      cell.setAttribute("tabindex", "-1");
      cell.appendChild(slot);
    }
    cell._content = cellContent;
    cellContent.addEventListener("mousedown", () => {
      if (isChrome) {
        const mouseUpListener = (event) => {
          const contentContainsFocusedElement = cellContent.contains(this.getRootNode().activeElement);
          const mouseUpWithinCell = event.composedPath().includes(cellContent);
          if (!contentContainsFocusedElement && mouseUpWithinCell) {
            cell.focus({ preventScroll: true });
          }
          document.removeEventListener("mouseup", mouseUpListener, true);
        };
        document.addEventListener("mouseup", mouseUpListener, true);
      } else {
        setTimeout(() => {
          if (!cellContent.contains(this.getRootNode().activeElement)) {
            cell.focus({ preventScroll: true });
          }
        });
      }
    });
    return cell;
  }
  __initRow(row, columns, section = "body", isColumnRow = false, noNotify = false) {
    const contentsFragment = document.createDocumentFragment();
    iterateRowCells(row, (cell) => {
      cell._vacant = true;
    });
    row.innerHTML = "";
    if (section === "body") {
      row.__cells = [];
      row.__detailsCell = null;
    }
    columns.filter((column) => !column.hidden).forEach((column, index, cols) => {
      let cell;
      if (section === "body") {
        if (!column._cells) {
          column._cells = [];
        }
        cell = column._cells.find((cell2) => cell2._vacant);
        if (!cell) {
          cell = this._createCell("td", column);
          if (column._onCellKeyDown) {
            cell.addEventListener("keydown", column._onCellKeyDown.bind(column));
          }
          column._cells.push(cell);
        }
        updatePart(cell, "cell", true);
        updatePart(cell, "body-cell", true);
        cell.__parentRow = row;
        row.__cells.push(cell);
        const isSizerRow = row === this.$.sizer;
        if (!column._bodyContentHidden || isSizerRow) {
          row.appendChild(cell);
        }
        if (isSizerRow) {
          column._sizerCell = cell;
        }
        if (index === cols.length - 1 && this.rowDetailsRenderer) {
          if (!this._detailsCells) {
            this._detailsCells = [];
          }
          const detailsCell = this._detailsCells.find((cell2) => cell2._vacant) || this._createCell("td");
          if (this._detailsCells.indexOf(detailsCell) === -1) {
            this._detailsCells.push(detailsCell);
          }
          if (!detailsCell._content.parentElement) {
            contentsFragment.appendChild(detailsCell._content);
          }
          this._configureDetailsCell(detailsCell);
          row.appendChild(detailsCell);
          row.__detailsCell = detailsCell;
          this.__a11ySetRowDetailsCell(row, detailsCell);
          detailsCell._vacant = false;
        }
        if (!noNotify) {
          column._cells = [...column._cells];
        }
      } else {
        const tagName = section === "header" ? "th" : "td";
        if (isColumnRow || column.localName === "vaadin-grid-column-group") {
          cell = column[`_${section}Cell`];
          if (!cell) {
            cell = this._createCell(tagName);
            if (column._onCellKeyDown) {
              cell.addEventListener("keydown", column._onCellKeyDown.bind(column));
            }
          }
          cell._column = column;
          row.appendChild(cell);
          column[`_${section}Cell`] = cell;
        } else {
          if (!column._emptyCells) {
            column._emptyCells = [];
          }
          cell = column._emptyCells.find((cell2) => cell2._vacant) || this._createCell(tagName);
          cell._column = column;
          row.appendChild(cell);
          if (column._emptyCells.indexOf(cell) === -1) {
            column._emptyCells.push(cell);
          }
        }
        updatePart(cell, "cell", true);
        updatePart(cell, `${section}-cell`, true);
      }
      if (!cell._content.parentElement) {
        contentsFragment.appendChild(cell._content);
      }
      cell._vacant = false;
      cell._column = column;
    });
    if (section !== "body") {
      this.__debounceUpdateHeaderFooterRowVisibility(row);
    }
    this.appendChild(contentsFragment);
    this._frozenCellsChanged();
    this._updateFirstAndLastColumnForRow(row);
  }
  __debounceUpdateHeaderFooterRowVisibility(row) {
    row.__debounceUpdateHeaderFooterRowVisibility = Debouncer.debounce(row.__debounceUpdateHeaderFooterRowVisibility, microTask, () => this.__updateHeaderFooterRowVisibility(row));
  }
  __updateHeaderFooterRowVisibility(row) {
    if (!row) {
      return;
    }
    const visibleRowCells = Array.from(row.children).filter((cell) => {
      const column = cell._column;
      if (column._emptyCells && column._emptyCells.indexOf(cell) > -1) {
        return false;
      }
      if (row.parentElement === this.$.header) {
        if (column.headerRenderer) {
          return true;
        }
        if (column.header === null) {
          return false;
        }
        if (column.path || column.header !== undefined) {
          return true;
        }
      } else if (column.footerRenderer) {
        return true;
      }
      return false;
    });
    if (row.hidden !== !visibleRowCells.length) {
      row.hidden = !visibleRowCells.length;
    }
    if (row.parentElement === this.$.header) {
      this.$.table.toggleAttribute("has-header", this.$.header.querySelector("tr:not([hidden])"));
      this.__updateHeaderFooterRowParts("header");
    }
    if (row.parentElement === this.$.footer) {
      this.$.table.toggleAttribute("has-footer", this.$.footer.querySelector("tr:not([hidden])"));
      this.__updateHeaderFooterRowParts("footer");
    }
    this._resetKeyboardNavigation();
    this.__a11yUpdateGridSize(this.size, this._columnTree, this.__emptyState);
  }
  _updateScrollerItem(row, index) {
    this._preventScrollerRotatingCellFocus(row, index);
    if (!this._columnTree) {
      return;
    }
    row.index = index;
    this.__ensureRowItem(row);
    this.__ensureRowHierarchy(row);
    this.__updateRow(row);
  }
  _columnTreeChanged(columnTree) {
    this._renderColumnTree(columnTree);
    this.__updateColumnsBodyContentHidden();
  }
  __updateRowOrderParts(row) {
    updateBooleanRowStates(row, {
      first: row.index === 0,
      last: row.index === this._flatSize - 1,
      odd: row.index % 2 !== 0,
      even: row.index % 2 === 0
    });
  }
  __updateRowStateParts(row, { item, expanded, selected, detailsOpened }) {
    updateBooleanRowStates(row, {
      expanded,
      collapsed: this.__isRowExpandable(row),
      selected,
      nonselectable: this.__isItemSelectable(item) === false,
      "details-opened": detailsOpened
    });
  }
  __computeEmptyState(flatSize, hasEmptyStateContent) {
    return flatSize === 0 && hasEmptyStateContent;
  }
  _renderColumnTree(columnTree) {
    iterateChildren(this.$.items, (row) => {
      this.__initRow(row, columnTree[columnTree.length - 1], "body", false, true);
      this.__updateRow(row);
    });
    while (this.$.header.children.length < columnTree.length) {
      const headerRow = document.createElement("tr");
      headerRow.setAttribute("role", "row");
      headerRow.setAttribute("tabindex", "-1");
      updatePart(headerRow, "row", true);
      updatePart(headerRow, "header-row", true);
      this.$.header.appendChild(headerRow);
      const footerRow = document.createElement("tr");
      footerRow.setAttribute("role", "row");
      footerRow.setAttribute("tabindex", "-1");
      updatePart(footerRow, "row", true);
      updatePart(footerRow, "footer-row", true);
      this.$.footer.appendChild(footerRow);
    }
    while (this.$.header.children.length > columnTree.length) {
      this.$.header.removeChild(this.$.header.firstElementChild);
      this.$.footer.removeChild(this.$.footer.firstElementChild);
    }
    iterateChildren(this.$.header, (headerRow, index) => {
      this.__initRow(headerRow, columnTree[index], "header", index === columnTree.length - 1);
    });
    iterateChildren(this.$.footer, (footerRow, index) => {
      this.__initRow(footerRow, columnTree[columnTree.length - 1 - index], "footer", index === 0);
    });
    this.__initRow(this.$.sizer, columnTree[columnTree.length - 1]);
    this.__updateHeaderFooterRowParts("header");
    this.__updateHeaderFooterRowParts("footer");
    this._resizeHandler();
    this._frozenCellsChanged();
    this._updateFirstAndLastColumn();
    this._resetKeyboardNavigation();
    this.__a11yUpdateHeaderRows();
    this.__a11yUpdateFooterRows();
    this.generateCellPartNames();
    this.__updateHeaderAndFooter();
  }
  __updateHeaderFooterRowParts(section) {
    const visibleRows = [...this.$[section].querySelectorAll("tr:not([hidden])")];
    [...this.$[section].children].forEach((row) => {
      updatePart(row, `first-${section}-row`, row === visibleRows.at(0));
      updatePart(row, `last-${section}-row`, row === visibleRows.at(-1));
      getBodyRowCells(row).forEach((cell) => {
        updatePart(cell, `first-${section}-row-cell`, row === visibleRows.at(0));
        updatePart(cell, `last-${section}-row-cell`, row === visibleRows.at(-1));
      });
    });
  }
  __updateRowLoading(row, loading) {
    const cells = getBodyRowCells(row);
    updateState(row, "loading", loading);
    updateCellsPart(cells, "loading-row-cell", loading);
    if (loading) {
      this._generateCellPartNames(row);
    }
  }
  __updateRow(row) {
    this.__a11yUpdateRowRowindex(row);
    this.__updateRowOrderParts(row);
    const item = this.__getRowItem(row);
    if (item) {
      this.__updateRowLoading(row, false);
    } else {
      this.__updateRowLoading(row, true);
      return;
    }
    row._item = item;
    const model = this.__getRowModel(row);
    this._toggleDetailsCell(row, model.detailsOpened);
    this.__a11yUpdateRowLevel(row, model.level);
    this.__a11yUpdateRowSelected(row, model.selected);
    this.__updateRowStateParts(row, model);
    this._generateCellPartNames(row, model);
    this._filterDragAndDrop(row, model);
    this.__updateDragSourceParts(row, model);
    iterateChildren(row, (cell) => {
      if (cell._column && !cell._column.isConnected) {
        return;
      }
      if (cell._renderer) {
        const owner = cell._column || this;
        cell._renderer.call(owner, cell._content, owner, model);
      }
    });
    this._updateDetailsCellHeight(row);
    this.__a11yUpdateRowExpanded(row, model.expanded);
  }
  _resizeHandler() {
    this._updateDetailsCellHeights();
    this.__updateHorizontalScrollPosition();
  }
  __getRowModel(row) {
    return {
      index: row.index,
      item: row._item,
      level: this.__getRowLevel(row),
      expanded: this._isExpanded(row._item),
      selected: this._isSelected(row._item),
      hasChildren: this._hasChildren(row._item),
      detailsOpened: !!this.rowDetailsRenderer && this._isDetailsOpened(row._item)
    };
  }
  _showTooltip(event) {
    const tooltip = this._tooltipController.node;
    if (tooltip && tooltip.isConnected) {
      const target = event.target;
      if (!this.__isCellFullyVisible(target)) {
        return;
      }
      this._tooltipController.setTarget(target);
      this._tooltipController.setContext(this.getEventContext(event));
      tooltip._stateController.open({
        focus: event.type === "focusin",
        hover: event.type === "mouseenter"
      });
    }
  }
  __isCellFullyVisible(cell) {
    if (cell.hasAttribute("frozen") || cell.hasAttribute("frozen-to-end")) {
      return true;
    }
    let { left, right } = this.getBoundingClientRect();
    const frozen = [...cell.parentNode.children].find((cell2) => cell2.hasAttribute("last-frozen"));
    if (frozen) {
      const frozenRect = frozen.getBoundingClientRect();
      left = this.__isRTL ? left : frozenRect.right;
      right = this.__isRTL ? frozenRect.left : right;
    }
    const frozenToEnd = [...cell.parentNode.children].find((cell2) => cell2.hasAttribute("first-frozen-to-end"));
    if (frozenToEnd) {
      const frozenToEndRect = frozenToEnd.getBoundingClientRect();
      left = this.__isRTL ? frozenToEndRect.right : left;
      right = this.__isRTL ? right : frozenToEndRect.left;
    }
    const cellRect = cell.getBoundingClientRect();
    return cellRect.left >= left && cellRect.right <= right;
  }
  _hideTooltip(immediate) {
    const tooltip = this._tooltipController && this._tooltipController.node;
    if (tooltip) {
      tooltip._stateController.close(immediate);
    }
  }
  requestContentUpdate() {
    this.__updateHeaderAndFooter();
    this.__updateVisibleRows();
  }
  __updateHeaderAndFooter() {
    (this._columnTree || []).forEach((level) => {
      level.forEach((column) => {
        if (column._renderHeaderAndFooter) {
          column._renderHeaderAndFooter();
        }
      });
    });
  }
  __updateVisibleRows(start, end) {
    if (this.__virtualizer) {
      this.__virtualizer.update(start, end);
    }
  }
  __updateMinHeight() {
    const rowHeight = 36;
    const headerHeight = this.$.header.clientHeight;
    const footerHeight = this.$.footer.clientHeight;
    const scrollbarHeight = this.$.table.offsetHeight - this.$.table.clientHeight;
    const minHeight = headerHeight + rowHeight + footerHeight + scrollbarHeight;
    if (!this.__minHeightStyleSheet) {
      this.__minHeightStyleSheet = new CSSStyleSheet;
      this.shadowRoot.adoptedStyleSheets.push(this.__minHeightStyleSheet);
    }
    this.__minHeightStyleSheet.replaceSync(`:host { --_grid-min-height: ${minHeight}px; }`);
  }
};

// node_modules/@vaadin/grid/src/vaadin-grid.js
class Grid extends GridMixin(ElementMixin(ThemableMixin(PolylitMixin(LumoInjectionMixin(LitElement))))) {
  static get is() {
    return "vaadin-grid";
  }
  static get styles() {
    return gridStyles;
  }
  render() {
    return html`
      <div
        id="scroller"
        ?safari="${this._safari}"
        ?ios="${this._ios}"
        ?loading="${this.loading}"
        ?column-reordering-allowed="${this.columnReorderingAllowed}"
        ?empty-state="${this.__emptyState}"
      >
        <table
          id="table"
          role="treegrid"
          aria-multiselectable="true"
          tabindex="0"
          aria-label="${ifDefined(this.accessibleName)}"
        >
          <caption id="sizer" part="row"></caption>
          <thead id="header" role="rowgroup"></thead>
          <tbody id="items" role="rowgroup"></tbody>
          <tbody id="emptystatebody">
            <tr id="emptystaterow">
              <td part="empty-state" class="empty-state" id="emptystatecell" tabindex="0">
                <slot name="empty-state" id="emptystateslot"></slot>
              </td>
            </tr>
          </tbody>
          <tfoot id="footer" role="rowgroup"></tfoot>
        </table>

        <div part="reorder-ghost" class="reorder-ghost"></div>
      </div>

      <slot name="tooltip"></slot>

      <div id="focusexit" tabindex="0"></div>
    `;
  }
}
defineCustomElement(Grid);
// export {
//   GridColumn,
//   Grid,
//   ColumnBaseMixin
// };
