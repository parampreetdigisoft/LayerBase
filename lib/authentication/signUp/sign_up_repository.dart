import 'package:ecrumedia/authentication/signUp/question_response_model.dart';
import 'package:ecrumedia/utils/app_strings.dart';

class SignUpRepository {
  fetchSecurityQuestion() {
    return [
      QuestionResponseModel(
        id: "1",
        question: AppStrings.whatWasYourChildhoodNickname,
      ),
      QuestionResponseModel(
        id: "2",
        question: AppStrings.whatIsYourFavoriteFood,
      ),
      QuestionResponseModel(
        id: "3",
        question: AppStrings.whereDidYouGoOnYourFirstVacation,
      ),
      QuestionResponseModel(
        id: "4",
        question: AppStrings.whatIsYourMothersMaidenName,
      ),
      QuestionResponseModel(
        id: "5",
        question: AppStrings.whatIsTheNameOfTheStreetYouGrewUpOn,
      ),
      QuestionResponseModel(
        id: "6",
        question: AppStrings.whatWasTheNameOfTheFirstPet,
      ),
      QuestionResponseModel(
        id: "7",
        question: AppStrings.whatIsYourFavoriteTeachersName,
      ),
      QuestionResponseModel(
        id: "8",
        question: AppStrings.whatWasTheNameOfTheElementarySchool,
      ),
      QuestionResponseModel(
        id: "9",
        question: AppStrings.whatIsYourFavoriteMovie,
      ),
      QuestionResponseModel(
        id: "10",
        question: AppStrings.whatWasTheMakeAndModelOfTheFirstCar,
      ),
      QuestionResponseModel(
        id: "11",
        question: AppStrings.whoIsYourFavoriteSportsTeam,
      ),
      QuestionResponseModel(
        id: "12",
        question: AppStrings.inWhatCityWereYouBorn,
      ),
    ];
  }
}
