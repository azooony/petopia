"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.storageClient = exports.LocalStorageClient = void 0;
var LocalStorageClient_1 = require("./LocalStorageClient");
Object.defineProperty(exports, "LocalStorageClient", { enumerable: true, get: function () { return LocalStorageClient_1.LocalStorageClient; } });
const LocalStorageClient_2 = require("./LocalStorageClient");
// Default storage client instance for local storage
exports.storageClient = new LocalStorageClient_2.LocalStorageClient("uploads", "/uploads");
//# sourceMappingURL=index.js.map