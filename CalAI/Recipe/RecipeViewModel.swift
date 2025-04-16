//
//  RecipeViewModel.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.
//

import SwiftUI

struct ResultView: View {
    let task: TaskResponse?
    @ObservedObject var viewModel: RecipeViewModel
    let category: String
    let image: UIImage?
    @State private var navigateToRecipeDetail = false
    @State private var savedRecipe: Recipe?
    @State private var showSheet = false // State to control sheet presentation
    @Environment(\.dismiss) var dismiss
    
    // Track visit count using UserDefaults
    private let visitCountKey = "ResultViewVisitCount"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let task = task, let comment = task.comment {
                    Text("Description")
                        .font(.headline)
                        .padding(.horizontal)
                    Text(comment)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                HStack {
                    Spacer()
                    if let totalCalories = task?.totalKilocalories {
                        Text("+ \(Int(totalCalories.rounded()))")
                            .foregroundColor(.green)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        + Text(" kcal")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                
                if let items = task?.items {
                    ForEach(items, id: \.id) { item in
                        NavigationLink(destination: ItemDetailView(item: item, comment: task?.comment, image: image).navigationBarBackButtonHidden(true)) {
                            VStack {
                                if let items = task?.items, let firstItem = items.first {
                                    let totalProteins = (firstItem.weight ?? 0.0) / 100.0 * (firstItem.proteinsPer100g ?? 0.0)
                                    let totalCarbs = (firstItem.weight ?? 0.0) / 100.0 * (firstItem.carbohydratesPer100g ?? 0.0)
                                    let totalFats = (firstItem.weight ?? 0.0) / 100.0 * (firstItem.fatsPer100g ?? 0.0)
                                    
                                    HStack {
                                        NutritionView(value: Int(totalProteins.rounded()), label: "protein")
                                        NutritionView(value: Int(totalCarbs.rounded()), label: "carbs")
                                        NutritionView(value: Int(totalFats.rounded()), label: "fats")
                                    }
                                    .padding(.horizontal)
                                }
                                ItemRow(item: item, image: image)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(Color(hex: "#FFFFFF").opacity(0.1))
                    .cornerRadius(32)
                } else {
                    Text("No items to display")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    saveRecipe()
                    if let task = task {
                        let name = task.items?.first?.product ?? "Untitled"
                        let calories = Int(task.totalKilocalories?.rounded() ?? 0)
                        let items = task.items ?? []
                        let totalProteins = items.reduce(0) { $0 + (($1.weight ?? 0) / 100.0 * ($1.proteinsPer100g ?? 0)) }
                        let totalCarbs = items.reduce(0) { $0 + (($1.weight ?? 0) / 100.0 * ($1.carbohydratesPer100g ?? 0)) }
                        let totalFats = items.reduce(0) { $0 + (($1.weight ?? 0) / 100.0 * ($1.fatsPer100g ?? 0)) }
                        let description = task.comment ?? "No description"
                        let ingredients = items.flatMap { item -> [String] in
                            if let itemIngredients = item.ingredients, !itemIngredients.isEmpty {
                                return itemIngredients.map { ingredient in
                                    let name = ingredient.ingredient
                                    let weight = ingredient.weight
                                    return "\(name) (\(weight) g)"
                                }
                            } else if let product = item.product {
                                return [product]
                            }
                            return ["Unknown ingredient"]
                        }
                        let imageName = image != nil ? saveImageToDisk(image: image!) : nil
                        
                        savedRecipe = Recipe(
                            name: name,
                            category: category,
                            calories: calories,
                            protein: Int(totalProteins.rounded()),
                            carbs: Int(totalCarbs.rounded()),
                            fats: Int(totalFats.rounded()),
                            description: description,
                            ingredients: ingredients,
                            imageName: imageName
                        )
                    }
                    dismiss()
                }) {
                    Text("\(Image(systemName: "checkmark")) Save")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#0FB423"))
                        .cornerRadius(32)
                        .padding(.horizontal)
                }
            }
            .navigationTitle(category)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                let visitCount = UserDefaults.standard.integer(forKey: visitCountKey) + 1
                UserDefaults.standard.set(visitCount, forKey: visitCountKey)
                
                if visitCount == 1 || visitCount == 6 {
                    showSheet = true
                }
            }
            .sheet(isPresented: $showSheet) {
                FeedbackView()
            }
        }
    }
    
    private func saveRecipe() {
        guard let task = task else { return }
        
        let name = task.items?.first?.product ?? "Untitled"
        let category = category
        let calories = Int(task.totalKilocalories?.rounded() ?? 0)
        let items = task.items ?? []
        let totalProteins = items.reduce(0) { $0 + (($1.weight ?? 0) / 100.0 * ($1.proteinsPer100g ?? 0)) }
        let totalCarbs = items.reduce(0) { $0 + (($1.weight ?? 0) / 100.0 * ($1.carbohydratesPer100g ?? 0)) }
        let totalFats = items.reduce(0) { $0 + (($1.weight ?? 0) / 100.0 * ($1.fatsPer100g ?? 0)) }
        let description = task.comment ?? "No description"
        let ingredients = items.flatMap { item -> [String] in
            if let itemIngredients = item.ingredients, !itemIngredients.isEmpty {
                return itemIngredients.map { ingredient in
                    let name = ingredient.ingredient
                    let weight = ingredient.weight
                    return "\(name) (\(weight) g)"
                }
            } else if let product = item.product {
                return [product]
            }
            return ["Unknown ingredient"]
        }
        
        var imageName: String? = nil
        if let image = image {
            imageName = saveImageToDisk(image: image)
        }
        
        viewModel.addRecipe(
            name: name,
            category: category,
            calories: calories,
            protein: Int(totalProteins.rounded()),
            carbs: Int(totalCarbs.rounded()),
            fats: Int(totalFats.rounded()),
            description: description,
            ingredients: ingredients,
            imageName: imageName
        )
    }
    
    private func saveImageToDisk(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
        let fileName = UUID().uuidString + ".jpg"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}

#Preview {
    NavigationStack {
        ResultView(
            task: TaskResponse.mock(),
            viewModel: RecipeViewModel(),
            category: "Breakfast",
            image: nil
        )
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe
    @ObservedObject var viewModel: RecipeViewModel
    @ObservedObject var calorieViewModel: CalorieViewModel
    @State private var selectedTab: String = "Ingredients"
    @Environment(\.dismiss) var dismiss
    @State private var isShowingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(recipe.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Text("+ \(recipe.calories)")
                        .foregroundColor(.green)
                        .font(.title)
                        .fontWeight(.bold)
                    + Text(" kcal")
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                
                ZStack(alignment: .bottom) {
                    if let imageName = recipe.imageName, let uiImage = loadImageFromDisk(imageName: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        NutritionView(value: recipe.protein, label: "protein")
                        NutritionView(value: recipe.carbs, label: "carbs")
                        NutritionView(value: recipe.fats, label: "fats")
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                }
                
                Text("Description")
                    .font(.system(size: 20))
                    .padding(.horizontal)
                Text(recipe.description)
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Picker("Select Section", selection: $selectedTab) {
                    Text("Ingredients").tag("Ingredients")
                    Text("Recipe").tag("Recipe")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .colorMultiply(.green)
                .tint(.green)
                
                if selectedTab == "Ingredients" {
                    if !recipe.ingredients.isEmpty {
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            let parsed = parseIngredient(ingredient)
                            HStack {
                                Text(parsed.name.capitalized)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(parsed.weight)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .padding(.horizontal)
                        }
                    } else {
                        Text("No ingredients available")
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    Text("Recipe content goes here")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    saveAsMeal()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add to the diet")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#0FB423"))
                    .cornerRadius(32)
                    .padding(.horizontal)
                }
            }
            .navigationTitle(recipe.category)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        isShowingEditSheet = true
                    }
                }
            }
            .sheet(isPresented: $isShowingEditSheet) {
                EditRecipeView(isPresented: $isShowingEditSheet, viewModel: viewModel, recipe: recipe)
                    .presentationDetents([.medium])
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func saveAsMeal() {
        let meal = Meal(
            name: recipe.name,
            calories: recipe.calories,
            protein: recipe.protein,
            carbs: recipe.carbs,
            fats: recipe.fats,
            imageName: recipe.imageName
        )
        calorieViewModel.addMeal(meal, to: recipe.category)
    }
    
    private func loadImageFromDisk(imageName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(imageName)
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
    
    private func parseIngredient(_ ingredient: String) -> (name: String, weight: String) {
        guard let openBracketIndex = ingredient.firstIndex(of: "("),
              let closeBracketIndex = ingredient.firstIndex(of: ")"),
              openBracketIndex < closeBracketIndex else {
            return (name: ingredient, weight: "N/A")
        }
        
        let name = String(ingredient[..<openBracketIndex]).trimmingCharacters(in: .whitespaces)
        let weightStartIndex = ingredient.index(after: openBracketIndex)
        let weightRange = weightStartIndex..<closeBracketIndex
        let weightWithUnit = String(ingredient[weightRange]).trimmingCharacters(in: .whitespaces)
        let weight = weightWithUnit.replacingOccurrences(of: "g", with: "").trimmingCharacters(in: .whitespaces)
        
        return (name: name, weight: weight)
    }
}

struct NutritionView: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack {
            Text("\(value)g")
                .font(.headline)
                .foregroundColor(Color(hex: "#0FB423"))
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}


class RecipeViewModel: ObservableObject {
    @Published var categories: [Category] = [
        Category(name: "Breakfast", count: 0),
        Category(name: "Lunch", count: 0),
        Category(name: "Dinner", count: 0),
        Category(name: "Snack", count: 0),
        Category(name: "Other", count: 0)
    ]
    
    @Published var recipes: [Recipe] {
        didSet {
            saveRecipes()
            updateCategoryCounts()
        }
    }
    @Published var selectedCategory: String = "Breakfast"
    
    init() {
        self.recipes = RecipeViewModel.loadRecipes()
        updateCategoryCounts()
    }
    
    func reloadData() {
        self.recipes = RecipeViewModel.loadRecipes()
        updateCategoryCounts()
    }
    
    func addRecipe(name: String, category: String, calories: Int, protein: Int, carbs: Int, fats: Int, description: String, ingredients: [String], imageName: String?) {
        let newRecipe = Recipe(name: name, category: category, calories: calories, protein: protein, carbs: carbs, fats: fats, description: description, ingredients: ingredients, imageName: imageName)
        recipes.append(newRecipe)
    }
    
    func recipesForSelectedCategory() -> [Recipe] {
        recipes.filter { $0.category == selectedCategory }
    }
    
    private func saveRecipes() {
        if let encoded = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(encoded, forKey: "SavedRecipes")
        }
    }
    
    static func loadRecipes() -> [Recipe] {
        if let data = UserDefaults.standard.data(forKey: "SavedRecipes"),
           let decoded = try? JSONDecoder().decode([Recipe].self, from: data) {
            return decoded
        }
        return []
    }
    
    private func updateCategoryCounts() {
        for category in categories {
            if let index = categories.firstIndex(where: { $0.name == category.name }) {
                categories[index].count = recipes.filter { $0.category == category.name }.count
            }
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes.remove(at: index)
        }
    }
}

struct EditRecipeView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: RecipeViewModel
    let recipe: Recipe
    
    @State private var selectedCategory: String
    let categories = ["Breakfast", "Lunch", "Dinner", "Snack", "Other"]
    
    init(isPresented: Binding<Bool>, viewModel: RecipeViewModel, recipe: Recipe) {
        self._isPresented = isPresented
        self.viewModel = viewModel
        self.recipe = recipe
        self._selectedCategory = State(initialValue: recipe.category)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Category")
                        .foregroundColor(.gray)
                        .padding(.leading)
                    Spacer()
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.white)
                    .padding(.trailing)
                }
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    saveChanges()
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Save")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#0FB423"))
                    .cornerRadius(32)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Editing")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
    
    private func saveChanges() {
        let updatedRecipe = Recipe(
            name: recipe.name,
            category: selectedCategory,
            calories: recipe.calories,
            protein: recipe.protein,
            carbs: recipe.carbs,
            fats: recipe.fats,
            description: recipe.description,
            ingredients: recipe.ingredients,
            imageName: recipe.imageName
        )
        
        if let index = viewModel.recipes.firstIndex(where: { $0.id == recipe.id }) {
            viewModel.recipes[index] = updatedRecipe
        }
    }
}

struct NutritionIcon: View {
    let value: Int
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .font(.caption)
            Text("\(value)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
