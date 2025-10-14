/**
 * Universal Base64 Encoding and Decoding
 * This script provides a simple, universal API for Base64 operations
 * that works correctly in both Node.js and browser environments,
 * including proper handling of Unicode characters.
 */

// Define an adapter object to house the functions
const base64 = {};

if (typeof Buffer !== 'undefined') {
  // Node.js environment using the Buffer class
  base64.encode = (str) => {
    return Buffer.from(str, 'utf-8').toString('base64');
  };

  base64.decode = (b64) => {
    return Buffer.from(b64, 'base64').toString('utf-8');
  };
} else if (typeof window !== 'undefined' && typeof window.atob === 'function') {
  // Browser environment using btoa() and atob()
  // Uses TextEncoder and TextDecoder to handle Unicode correctly
  base64.encode = (str) => {
    const utf8Bytes = new TextEncoder().encode(str);
    const binaryString = String.fromCharCode(...utf8Bytes);
    return window.btoa(binaryString);
  };

  base64.decode = (b64) => {
    const binaryString = window.atob(b64);
    const utf8Bytes = Uint8Array.from(binaryString, (m) => m.codePointAt(0));
    return new TextDecoder().decode(utf8Bytes);
  };
} else {
  // Fallback for older or non-standard environments
  base64.encode = () => {
    throw new Error('Base64 encoding is not supported in this environment.');
  };

  base64.decode = () => {
    throw new Error('Base64 decoding is not supported in this environment.');
  };
}

export default base64;
