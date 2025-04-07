class RepositoryException implements Exception {
  final String message;
  final String? details;

  const RepositoryException(this.message, {this.details});
}

class EntityNotFoundException extends RepositoryException {
  const EntityNotFoundException(super.message, {super.details});
}
