/*: [Previous](@previous)
 # 2. Model

 Model can call Service methods.

 Model provides methods to manipulate data.

 */
import Foundation
import RxSwift


protocol TaskRepository {
    func save(task: TaskEntity)
}

protocol ProjectRepository {
    func save(project: ProjectEntity)
}

protocol TransactionEntity {
    func transaction<Result>(run: () -> Result) throws -> Result
}

protocol TaskEntity: AnyObject {
    var name: String { get set }

    var subtasks: [TaskEntity] { get set }
}

protocol ProjectEntity: AnyObject {
    var tasks: [TaskEntity] { get set }
}

protocol HasIdentifier {
    associatedtype IdentifierType: Hashable

    var id: Id<Self> { get set }
}

struct Id<Entity: HasIdentifier>: Hashable {
    var value: Entity.IdentifierType
}

struct Project: HasIdentifier {
    typealias IdentifierType = String

    var id: Id<Project>
}

struct Task: HasIdentifier {
    typealias IdentifierType = String

    var id: Id<Task>
    var text: String
    var color: Color
    var parentId: Id<Project>

    enum Color {
        case red
        case rgb(String)
    }
}

class PendingModel<T> {

}

open class ModelProvider<Identifier: Hashable, Model: AnyObject> {
    private struct WeakBox {
        weak var object: Model?
    }

    private let factory: (Identifier) throws -> Model

    private var models: [Identifier: WeakBox] = [:]

    public init(factory: @escaping (Identifier) throws -> Model) {
        self.factory = factory
    }

    open func model(forId id: Identifier) throws -> Model {
        if let model = try models[id]?.object {
            return model
        } else {
            let model = factory(id)
            models[id] = WeakBox(object: model)
            return model
        }
    }
}

typealias IdentifiedModelProvider<Model: AnyObject & HasIdentifier> = ModelProvider<Model.IdentifierType, Model>

class OptionallyIdentifiedModelProvider<Model: AnyObject & HasIdentifier>: ModelProvider<Model.IdentifierType?, Model> {

}

protocol TaskRepository {
    func save(task: TaskEntity)
}

class TaskModel {
    enum Parent {
        case project(ProjectModel)
        indirect case task(TaskModel)
    }

    private(set) var task: Task

//    private var entity: TaskEntity
    private(set) var parent: Parent
    private(set) var subtasks: [TaskModel]

    init(parent: Parent, subtasks: [TaskModel]) {
        self.parent = parent
        self.subtasks = subtasks
    }

    init(repository: TaskRepository, modelProvider: IdentifiedModelProvider<TaskModel>, id: String) {
    }

    func set(dueDate: Date) -> Completable {
        var task = self.task
        task.dueDate = dueDate
        return repository.save(task: task).onComplete { self.task = task }
    }

    func createSubtask(name: String) {
//        modelProvider.creating {
//            model.name = task.name
//        }
    }

    func move(to targetParent: Parent) {
        switch parent {
        case .project(let project):
            project.remove(task: self)
        case .task(let task):
            task.remove(subtask: self)
        }

        parent = targetParent

        switch targetParent {
        case .project(let project):
            project.add(task: self)
        case .task(let task):
            task.add(subtask: self)
        }
    }

    func add(subtask: TaskModel) {
        subtasks.append(subtask)
    }

    func remove(subtask: TaskModel) {
        guard let index = subtasks.firstIndex(where: { $0 === subtask }) else {
            print("Subtask \(subtask) is not contained in \(self), can't remove!")
            return
        }
        subtasks.remove(at: index)
    }
}

class ProjectModel {
    private var tasks: [TaskModel]

    init(tasks: [TaskModel]) {
        self.tasks = tasks
    }

    func add(task: TaskModel, at index: Int = -1) {
        if tasks.indices.contains(index) {
            tasks.insert(task, at: index)
        } else {
            tasks.append(task)
        }
    }

    func remove(task: TaskModel) {
        guard let index = tasks.firstIndex(where: { $0 === task }) else {
            print("Task \(task) is not contained in \(self), can't remove!")
            return
        }
        tasks.remove(at: index)
    }
}

print("👍")

//: [Next](@next)
