import 'package:equatable/equatable.dart';

/// Academic Phase entity (e.g., Lycée, Collège)
class AcademicPhase extends Equatable {
  final int id;
  final String nameAr;
  final String? slug;
  final int? order;

  const AcademicPhase({
    required this.id,
    required this.nameAr,
    this.slug,
    this.order,
  });

  @override
  List<Object?> get props => [id, nameAr, slug, order];
}

/// Academic Year entity (e.g., 1AS, 2AS, 3AS)
class AcademicYear extends Equatable {
  final int id;
  final String nameAr;
  final int? levelNumber;
  final int? order;
  final int? academicPhaseId;

  const AcademicYear({
    required this.id,
    required this.nameAr,
    this.levelNumber,
    this.order,
    this.academicPhaseId,
  });

  @override
  List<Object?> get props => [id, nameAr, levelNumber, order, academicPhaseId];
}

/// Academic Stream entity (e.g., Sciences, Maths, Lettres)
class AcademicStream extends Equatable {
  final int id;
  final String nameAr;
  final String? slug;
  final String? descriptionAr;
  final int? order;

  const AcademicStream({
    required this.id,
    required this.nameAr,
    this.slug,
    this.descriptionAr,
    this.order,
  });

  @override
  List<Object?> get props => [id, nameAr, slug, descriptionAr, order];
}

/// Academic Setup Response (for phases API)
class AcademicPhasesResponse extends Equatable {
  final List<AcademicPhase> phases;

  const AcademicPhasesResponse({required this.phases});

  @override
  List<Object?> get props => [phases];
}

/// Academic Years Response
class AcademicYearsResponse extends Equatable {
  final AcademicPhase phase;
  final List<AcademicYear> years;

  const AcademicYearsResponse({required this.phase, required this.years});

  @override
  List<Object?> get props => [phase, years];
}

/// Academic Streams Response
class AcademicStreamsResponse extends Equatable {
  final AcademicYear year;
  final List<AcademicStream> streams;

  const AcademicStreamsResponse({required this.year, required this.streams});

  @override
  List<Object?> get props => [year, streams];
}
