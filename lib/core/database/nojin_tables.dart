import 'package:drift/drift.dart';

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 240)();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('general'))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Index> get customIndexes => [
        Index('notes_updated_at_idx', [updatedAt]),
        Index('notes_category_idx', [category]),
        Index('notes_archived_pinned_idx', [isArchived, isPinned]),
      ];
}

class FinanceAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 160)();
  TextColumn get accountType => text()();
  TextColumn get currency => text().withDefault(const Constant('toman'))();
  IntColumn get balance => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Index> get customIndexes => [
        Index('finance_accounts_updated_at_idx', [updatedAt]),
      ];
}

class FinanceTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get title => text().withLength(min: 1, max: 240)();
  IntColumn get amount => integer()();
  TextColumn get transactionType => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get occurredAt => integer()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Index> get customIndexes => [
        Index('finance_transactions_account_date_idx', [accountId, occurredAt]),
        Index('finance_transactions_date_idx', [occurredAt]),
      ];
}

class PlanningItems extends Table {
  TextColumn get id => text()();
  TextColumn get itemType => text()();
  TextColumn get title => text().withLength(min: 1, max: 240)();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get scheduledAt => integer().nullable()();
  IntColumn get dueAt => integer().nullable()();
  RealColumn get progress => real().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Index> get customIndexes => [
        Index('planning_items_type_status_idx', [itemType, status]),
        Index('planning_items_due_at_idx', [dueAt]),
      ];
}

class InfoItems extends Table {
  TextColumn get id => text()();
  TextColumn get itemType => text()();
  TextColumn get title => text().withLength(min: 1, max: 240)();
  TextColumn get content => text().withDefault(const Constant(''))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Index> get customIndexes => [
        Index('info_items_type_idx', [itemType]),
        Index('info_items_usage_idx', [usageCount]),
        Index('info_items_updated_at_idx', [updatedAt]),
      ];
}
