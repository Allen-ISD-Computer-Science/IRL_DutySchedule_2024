import Foundation
import CSV

let filename = "/home/david-ben-yaakov/irl/dutySchedules/AHS Conference periods 23-24.csv"

enum Semester {
    case Fall
    case Spring 
}

struct ClassSection {
    let identifier: String // data before slash
    let name: String
    let semester: Semester
    let period: Int
}

struct TeacherSections {
    let teacher: String
    let classSections: [ClassSection]
}

func parseTeacherSections(period: Int, sectionsString: String) -> [ClassSection]? {
    // Example section field:
    // "LA3E4A/09
    //  AP Eng IV
    //  01 - 02 - A
    //  ----------------
    //  LA3E4B/09
    //  AP Eng IV
    //   03 - 04 - A"
    
    // There's nothing to do if this is empty
    guard sectionsString.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
        return nil
    }

    // Loop over the count of sections
    // For each section, extract identier, name, and semester
    // The count of sections is determined by the count of "----------------" + 1
    var classSections : [ClassSection] = []
    let delimiter = "----------------"
    let sectionStrings = sectionsString.components(separatedBy: delimiter).map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    for sectionString in sectionStrings {
        let lines = sectionString.components(separatedBy: "\n")
        guard lines.count == 3 else {
            fatalError("Expected exactly three lines in \(lines) in \(sectionString)")
        }
        //print(">", lines[0])
        //print()
        //print(sectionString)
        let identifier = String(lines[0].components(separatedBy: "/")[0].trimmingCharacters(in: .whitespacesAndNewlines))
        let name = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
        switch lines[2].trimmingCharacters(in: .whitespacesAndNewlines).prefix(7) {
        case "01 - 02":
            classSections.append(ClassSection(identifier:identifier, name:name, semester:Semester.Fall, period:period))
        case "03 - 04":
            classSections.append(ClassSection(identifier:identifier, name:name, semester:Semester.Spring, period:period))
        case "01 - 04":
            classSections.append(ClassSection(identifier:identifier, name:name, semester:Semester.Fall, period:period))
            classSections.append(ClassSection(identifier:identifier, name:name, semester:Semester.Spring, period:period))
        default:
            fatalError("Expected either 01 - 02, 03 - 04, or 01 - 04 for quarters")
        }
    }
    return classSections
}

// Reads the file at pathname and returns an array of ordered records 
func readFile() throws {
    let stream = InputStream(fileAtPath: filename)!
    let csv = try! CSVReader(stream: stream)
    csv.next()
    while let row = csv.next() {
        print("Teacher: \(row[0])")
        print(parseTeacherSections(period: 1, sectionsString: row[2]) ?? "parseTeacherSections() returns nil")
    }
}

func main() throws {
    try readFile()
    print("Completed")
}

try main()
