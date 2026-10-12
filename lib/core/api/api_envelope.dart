// The API wraps every reply twice: the global envelope, then the handler's
// own { message, data }. Returns the innermost payload.
Map<String, dynamic> unwrapEnvelope(dynamic body) {
  final outer =
      (body as Map<String, dynamic>)['data'] as Map<String, dynamic>? ??
      const {};
  return outer['data'] as Map<String, dynamic>? ?? outer;
}
