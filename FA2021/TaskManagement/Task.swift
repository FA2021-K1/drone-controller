class Task {
	let id: String
	let name: String
	let type: TaskType
}

class FlyToTask:Task {
	let latitude: double
	let longitude: double
	let altitude: double
}

class NonTerminalTask:Task {
    task_ids: [String]
}